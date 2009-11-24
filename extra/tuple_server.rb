require 'logger'
require 'rinda/ring'
require 'rinda/tuplespace'

class TupleServer
  TIME_OUT = 180

  def initialize
    @logger = Logger.new(File.join(File.dirname(File.expand_path(__FILE__)), 'log',  "#{File.basename(__FILE__, '.*')}.log").tr('/', '\\'), 'daily')
    @logger.datetime_format = '%Y-%m-%d %H:%M '
    @logger.progname = self.class.name
    @logger.level = Logger::INFO

    @ts = Rinda::TupleSpaceProxy.new(Rinda::TupleSpace.new)
    @ts.write([:started_at, Time.now])
  end

  def write(tuple, time_out=true)
    @logger.debug("WRITE: #{tuple.inspect}")
    if time_out
      @ts.write(tuple, TIME_OUT)
    else
      @ts.write(tuple)
    end
  end

  def take(pattern, time_out=true, &block)
    @logger.debug("TAKE:  #{pattern.inspect}")
    if time_out
      @ts.take(pattern, TIME_OUT, &block)
    else
      @ts.take(pattern, nil, &block)
    end
  end

  def read(pattern, time_out=true)
    @logger.debug("READ:  #{pattern.inspect}")
    if time_out
      @ts.read(pattern, TIME_OUT)
    else
      @ts.read(pattern)
    end
  end

  def read_all(pattern)
    @logger.debug("READ_ALL: #{pattern.inspect}")
    @ts.read_all(pattern)
  end

  def notify(event, pattern, time_out=true)
    @logger.debug("NOTIFY: #{pattern.inspect}")
    if time_out
      @ts.notify(event, pattern, TIME_OUT)
    else
      @ts.notify(event, pattern)
    end
  end
end

if $0 == __FILE__
  case ARGV[0]
  when 'start', 'startlocal'
    if ARGV[0] == 'startlocal'
      DRb.start_service('druby://localhost:12345', TupleServer.new)
    else
      DRb.start_service
      ring_server = Rinda::RingServer.new(TupleServer.new)
    end
    puts DRb.uri
    DRb.thread.join
  when 'show', 'showlocal'
    ts = nil
    if ARGV[0] == 'showlocal'
      ts = DRbObject.new_with_uri('druby://localhost:12345')
    else
      DRb.start_service
      ts = Rinda::RingFinger.primary
    end
    tuples = ts.read_all([nil, nil])
    tuples.each{|t| puts t.inspect unless t.empty?}
  else
    puts "Usage: ruby #{File.basename(__FILE__)} [start|show]"
  end
end
