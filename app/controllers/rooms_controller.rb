class RoomsController < ApplicationController

    before_action :authenticate_user!
    before_action :set_room, only: [:show, :update, :destroy, :edit]
    layout :determine_layout

    def index
        @rooms = Room.all
    end

    def show
    end

    def new
        @room = Room.new
        authorize @room
    end

    def create
        @room = Room.new(room_params)
        authorize @room

        if @room.save
            flash[:notice] = "#{@room.name} was created successfully."
            redirect_to rooms_path
        else
            flash.now[:alert] = "Creation failed! Please check the name provided."
            render :new, status: :unprocessable_entity
        end
        
    end

    def edit
        authorize @room
    end

    def update
        if @room.update(room_params)
            flash[:notice] = "#{@room.name} was updated successfully."
            redirect_to rooms_path
        else
            flash.now[:alert] = "Creation failed! Please check the name provided."
            render :new, status: :unprocessable_entity
        end
        authorize @room
    end

    def destroy
        if @room.destroy 
            flash[:notice] = "#{@room.name} was deleted."
        else
            flash[:alert] = "Cannot delete #{@room.name}!"
        end
        redirect_to rooms_path
        authorize @room
    end

    def determine_layout
        current_user.member? ? "application" : "admin"
    end

    private 

    def set_room
        @room = Room.find(params[:id])
    end

    def room_params
        params.require(:room).permit(:name, :image)
    end

end