# coding: utf-8

require 'homebus'
require 'homebus/state'

require 'dotenv'

require 'time'
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
# {"Time":"2022-07-09T11:02:29.285032816-07:00","Offset":0,"Length":0,"Type":"SCM+","Message":{"FrameSync":5795,"ProtocolID":30,"EndpointType":188,"EndpointID":1011xxxxx,"Consumption":162430,"Tamper":768,"PacketCRC":37996}}

  # read a message from STDIN, process it and exit
  def work!
    pp @state

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

    pp 'state', @state

    if packet
      if @state.state[:consumption]
        flow = packet[:Message][:Consumption] - @state.state[:consumption]

        last_update_time = Time.at(@state.state[:last_update_time])
        current_update_time = Time.parse(packet[:Time])

        puts last_update_time.to_i, last_update_time
        puts current_update_time.to_i, current_update_time

        interval = current_update_time - last_update_time
      end

      @state.state[:consumption] = packet[:Message][:Consumption]
      @state.state[:last_update_time] = Time.parse(packet[:Time]).to_i
      @state.commit!

      if interval
        payload = {
          consumption: packet[:Message][:Consumption],
          flow: flow,
          interval: interval
        }

        puts @DDC, payload

        @device.publish! @DDC, payload
      end
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
