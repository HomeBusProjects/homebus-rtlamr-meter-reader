require 'homebus/options'

class RTLAMRHomebusAppOptions < Homebus::Options
  def app_options(op)
    zipcode_help = 'the zip code of the reporting area'

    op.separator 'RTLAMR options:'
  end

  def banner
    'HomeBus RTLAMR Meter Reader Publisher'
  end

  def version
    '0.0.1'
  end

  def name
    'homebus-rtlamr'
  end
end
