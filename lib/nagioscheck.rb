require "nagioscheck/version"

module NagiosCheck
  class Check
    OK,WARN,CRIT,UNKNOWN = 0,1,2,3
    OK_STR      = "OK"
    WARN_STR    = "WARNING"
    CRIT_STR    = "CRITICAL"
    UNKNOWN_STR = "UNKNOWN"

    attr_reader :exit_code
    attr_writer :exit_str, :perfdata
    attr_accessor :outputdata

    def initialize
      @exit_code  = OK
      @exit_str   = ""
      @perfdata   = nil
      @outputdata = ""
      @perfdata_objs = []
    end

    def exit
      puts exit_str
      return @exit_code
    end

    def exit!
      Process.exit exit
    end

    def exit_str
      str = case @exit_code
        when OK   then OK_STR
        when WARN then WARN_STR
        when CRIT then CRIT_STR
        else           UNKNOWN_STR
      end

      str += " - #{@outputdata}" unless @outputdata == ""
      str += perfdata
      return str
    end

    def perfdata
      str = ""
      if @perfdata_objs && @perfdata_objs.size > 0
        str = " |" 
        @perfdata_objs.each do |p|
          str += " '#{p.label}'=#{p.value}#{p.uom}"
          str += ";#{p.warn}" if p.warn
          str += ";#{p.crit}" if p.crit
          str += ";#{p.min}"  if p.min
          str += ";#{p.max}"  if p.max
        end
      elsif @perfdata && @perfdata != ""
        str = " |" +  @perfdata
      end
      return str
    end

    # set the exit code based on the warn_range and crit_range
    def set_exit_code ( value, warn_range, crit_range )
      result = OK
      if value.is_a?(Numeric) || value =~ /^\d+$/
        result = WARN if warn_range && range_match(value.to_i, warn_range)
        result = CRIT if crit_range && range_match(value.to_i, crit_range)
      else  
        result = WARN if value == warn_range
        result = CRIT if value == crit_range
      end
      self.exit_code = result
      return result
    end

# only sets the exit code if it is worse than the current exit code
    def exit_code=(exit_code)
      if exit_code > @exit_code
        if exit_code == UNKNOWN && @exit_code != OK
          # WARN and CRIT are higher priority than UNKNOWN
          return
        end
        @exit_code = exit_code
      end
    end

    def add_perfdata ( perfdata_obj )
      perfdata_obj = PerfData.new(perfdata_obj) if perfdata_obj.is_a? Hash
      perfdata_obj.warn = nil if perfdata_obj.warn == "nil"
      perfdata_obj.crit = nil if perfdata_obj.crit == "nil"
      @perfdata_objs << perfdata_obj
    end

  protected
    def is_range ( value ) 
      if value =~ /^(\d+)$/      ||
         value =~ /^(\d+):[~]?$/ ||
         value =~ /^~:(\d+)$/    ||
         value =~ /^(\d+):(\d+)$/
        return true
      end
      return false
    end

    # returns true if value is within range
    #10       < 0 or > 10, (outside the range of {0 .. 10})
    #10:      < 10, (outside {10 .. ∞})
    #~:10     > 10, (outside the range of {-∞ .. 10})
    # 10:20   < 10 or > 20, (outside the range of {10 .. 20})
    # @10:20  ≥ 10 and ≤ 20, (inside the range of {10 .. 20})
    def range_match ( value, range )
      return (value < 0 || value > range) if range.class != String

      result = false
      negate = (range =~ /^@(.*)/)
      range  = $1 if negate
      result = case range
        when /^(\d+)$/       then (value < 0 || value > $1.to_i)
      # untested from here to the end of the function
        when /^(\d+):[~]?$/  then (value < $1.to_i)
        when /^~:(\d+)$/     then (value > $1.to_i)
        when /^(\d+):(\d+)$/ then (value > $1.to_i && value < $2.to_i)
        when "nil"           then false
      end
      return negate ? !result : result
    end
  end

  class PerfData
    attr_accessor :label, :value, :uom, :warn, :crit, :min, :max

    def initialize (h={})
      @label, @value, @uom, @warn, @crit, @min, @max = nil, nil,nil,nil,nil,nil,nil
      unless h.empty?
        # weak sauce, but it gets the job done
        @label = h["label"] if h["label"]
        @value = h["value"] if h["value"]
        @uom   = h["uom"]   if h["uom"]
        @warn  = h["warn"]  if h["warn"]
        @crit  = h["crit"]  if h["crit"]
        @min   = h["min"]   if h["min"]
        @max   = h["max"]   if h["max"]
      end
    end
  end
end
