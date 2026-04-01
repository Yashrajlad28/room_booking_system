class BookingsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_booking, only: [:edit, :show, :destroy, :cancel, :update]
    layout :determine_layout

    def index
        # Only Admin can view this
        # @bookings = Booking.includes(:user, :room).all
        if current_user.member?
            @bookings = current_user.bookings
        else
            @bookings = Booking.includes(:user, :room)
        end
    end

    def edit
    end

    def update
        if @booking.update(booking_params)
            redirect_to api_v2_bookings_path, notice: "Booking edited successfully"
        else
            if @booking.conflicting_time_slots.present?
                flash.now[:alert] = "Conflicts with: #{@booking.conflicting_time_slots.join(', ')}"
            else
                flash.now[:alert] = @booking.errors.full_messages.join(", ")
            end

            render :edit, status: :unprocessable_entity
        end
    end

    def new 
        @booking = Booking.new

        # Check if the multi-parameter keys are present
        if params[:booking_date].present? && params[:"[start_time(4i)]"].present?
            @start_t = Time.zone.parse("#{params[:booking_date]} #{params[:"[start_time(4i)]"]}:#{params[:"[start_time(5i)]"]}")
            @end_t   = Time.zone.parse("#{params[:booking_date]} #{params[:"[end_time(4i)]"]}:#{params[:"[end_time(5i)]"]}")

            @booking.booking_date = params[:booking_date]
            @booking.start_time = @start_t
            @booking.end_time = @end_t
            
            @available_rooms = Room.check_availability(params[:booking_date], @start_t, @end_t)
        
        end
    end

    def create
        @booking = current_user.bookings.build(booking_params)

        if @booking.save
            redirect_to bookings_path, notice: "Room successfully booked!"
        else
            # flash.now[:alert] = @booking.errors.full_messages.to_sentence
            flash.now[:alert] = @booking.errors.full_messages.join(", ")
            render :new, status: :unprocessable_entity
        end
    end

    def show
    end

    def destroy
        if @booking.destroy
            flash[:notice] = "Booking successfully deleted"
        else 
            flash.now[:alert] = "Cannot be deleted"
        end
        redirect_to bookings_path
    end

    def cancel
        if @booking.cancelled!
            flash[:notice] = "Booking Cancelled Successfully"
        else
            flash.now[:alert] = "Cannot be cancelled"
        end
        redirect_to bookings_path
    end

    def determine_layout
        current_user.member? ? "application" : "admin"
    end

    private 

    def booking_params
        params.require(:booking).permit(
            :room_id,
            :booking_date,
            :start_time,
            :end_time,
            :"[start_time(4i)]", :"[start_time(5i)]",
            :"[end_time(4i)]", :"[end_time(5i)]"
        )
    end

    def set_booking
        @booking = Booking.find(params[:id])
    end

end