class Booking < ApplicationRecord
    # THIS IS JUST FOR VALIDATION
    belongs_to :user, optional: true
    belongs_to :room, optional: true

    enum :status, [:booked, :cancelled]

    validate :room_availability
    validate :booking_time_must_be_valid

    after_create :cleanup_old_bookings

    # creates method for accessing @conflicting_time_slots
    attr_accessor :conflicting_time_slots

  
    private

    def cleanup_old_bookings
        # This is not the best way since, this query will
        # run everytime new booking is created
        # CRON
        Booking.where("booking_date < ?", Date.today - 7).delete_all
    end

    def booking_time_must_be_valid
        # 1. Date cannot be in the past
        if booking_date < Date.today
            errors.add(:booking_date, "cannot be in the past")
            return
        end

        # 2. Date cannot be more than 1 week away
        if booking_date > 1.week.from_now.to_date
            errors.add(:booking_date, "can only be booked up to 1 week in advance")
            return
        end

        # 3. If booking for today, start_time cannot be in the past
        if booking_date == Date.today
            # We use our 'now_on_dummy_date' trick again to compare times accurately
            now = Time.current
            if start_time.strftime("%H:%M") < now.strftime("%H:%M")
                errors.add(:start_time, "cannot be in the past for today's bookings")
            end
        end

        # 4. end_time cannot be less than start_time
        if end_time.strftime("%H:%M") <= start_time.strftime("%H:%M")
            errors.add(:end_time, "cannot be before or equal to start time")
        end
        
    end

    def room_availability
        # add '::time' to tell Postgres the exact data type
        # .where.not(id: id) BOOKING CHECKED AGAINST ITSELF, WHILE CANCELLING IT, 
        # VALIDATION FAILED AND IT WAS NOT SAVED IN DATABASE
        overlapping_bookings = Booking.where(room_id: room_id, booking_date: booking_date)
                                        .where.not(id: id)
                                        .where(status: 0) 
                                        .where("(start_time, end_time) OVERLAPS (?::time, ?::time)", start_time, end_time)

        if overlapping_bookings.exists?
            # activates the setter
            self.conflicting_time_slots = overlapping_bookings.map do |b|
                [b.start_time.strftime("%I:%M %p"), b.end_time.strftime("%I:%M %p")] 
            end
            errors.add(:base, "Room is already booked for this time slot")
        end
    end

end