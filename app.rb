# coding: utf-8

require 'homebus'

require 'dotenv'

require 'net/http'
require 'json'

class RTLAMRHomebusApp < Homebus::App
  def initialize(options)
    @options = options
    super
  end

  def setup!
    Dotenv.load('.env')

    @DDC = ENV['DDC']
    @ID = ENV['ID']

    @device = Homebus::Device.new name: 'Homebus RTLAMR Meter Reader',
                                  manufacturer: 'Homebus',
                                  model: 'RTLAMR Meter',
                                  serial_number: @ID
  end

# messages look like:
# {"Time":"2022-07-09T11:02:29.285032816-07:00","Offset":0,"Length":0,"Type":"SCM+","Message":{"FrameSync":5795,"ProtocolID":30,"EndpointType":188,"EndpointID":101100604,"Consumption":162430,"Tamper":768,"PacketCRC":37996}}


  # read a message from STDIN, process it and exit
  def work!
    msg = gets
    puts "hbmr: #{msg}"

    if msg == nil
      puts "empty msg"
      exit
    end

    if options[:verbose]
      pp msg
    end

    begin
      packet = JSON.parse(msg, symbolize_names: true)
    rescue JSON::ParserError
      puts 'invalid JSON'
      exit
    end

    pp packet
    pp packet[:Message][:EndpointID], @ID.to_i

    if packet[:Message] && packet[:Message][:EndpointID] != @ID.to_i
      puts "not for us"
      exit
    end

    puts
    puts
    puts "GOT ONE FOR US"
    puts
    puts

    if packet
      payload = {
        consumption: packet[:Message][:Consumption]
      }


      puts @DDC, payload

      @device.publish! @DDC, payload
    end
  end

  def name
    "Homebus RTLAMR #{@type} Meter"
  end

  def publishes
    [ @DDC ]
  end

  def devices
    [ @device ]
  end
end
