class VisasByCountryController < ApplicationController

  def index
    nationalityRaw = params[:nationality]
    nationality = nationalityRaw.slice(0,1).capitalize + nationalityRaw.slice(1..-1).downcase

    if AllNationalities.check_if_exists(nationality)
      @data = read_visa_information(VisasByCountryApi.visas_for(nationality))
    else
      @data = "{\"countries:\"[]}"
    end

    render json: @data
  end

  private

  def read_visa_information(filename)
    return File.read(Rails.root+"lib/visa_requirements/"+filename)
  end

end
