class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.date :booking_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
