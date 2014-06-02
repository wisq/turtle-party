class PartyController < ApplicationController
  def checkin
    guest = Guest.find_or_initialize_by(id: params[:id])
    guest.dev_type = params[:dev_type]
    guest.label    = params[:label]
    guest.generate_label unless guest.label
    guest.active_at = Time.now

    is_new = guest.new_record?
    guest.save!

    logger.info "#{guest.description.capitalize} checking in#{' (first time)' if is_new}."

    render :json => guest
  end

  def next_task
    render :json => {:task => 'standby', :seconds => 15}
  end
end
