class Room < ApplicationRecord
    has_many :bookings
    has_many :users, through: :bookings

    before_validation :remove_extra_spaces

    validates :name, presence: true, format: { with: /\A[A-Za-z ]+\z/ }

    def self.check_availability(date, start_t, end_t)
        s_time = start_t.is_a?(String) ? Time.zone.parse("#{date} #{start_t}") : start_t
        e_time = end_t.is_a?(String) ? Time.zone.parse("#{date} #{end_t}") : end_t

        occupied_room_ids = Booking.where(booking_date: date)
                                    .where("(start_time::time, end_time::time) OVERLAPS (?::time, ?::time)", s_time, e_time)
                                    .where(status: 0)
                                    .pluck(:room_id)
        
        return Room.all if occupied_room_ids.empty?
        return Room.where.not(id: occupied_room_ids)
    end

    def currently_booked?
        # rails considers UTC by default for time
        # or you can config timezone in application.rb file


        # THIS DOES NOT WORK BECAUSE I WAS TRYING TO USE 
        # RUBY / RAILS METHOD seconds_since_midnight
        # IN POSTGRESQL
        # current_time = Time.current.seconds_since_midnight
        # bookings.where(booking_date: Date.today)
        #         .where(
        #             "start_time.seconds_since_midnight <= ? AND 
        #             end_time.seconds_since_midnight > ?", current_time, current_time)
        #         .exists?


        now = Time.current
        bookings.where(booking_date: Date.today)
                .where("start_time::time <= ?::time AND end_time::time > ?::time", now, now)
                .exists?

    end

    private 
    
    def remove_extra_spaces
        self.name = name.squish if name.present?
    end


end