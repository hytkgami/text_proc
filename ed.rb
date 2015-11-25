# coding:utf-8
class String
  def int?
    /\A\d+\z/ === self
  end
end

class Ed
  COMMAND = 0
  INSERT = 1
  def initialize(file)
    # ファイル内容を読み込んでおく
    @buffer = file.split("\n")
    @current = @buffer.size
    puts file.bytesize 
    @addr = '(?:\d+|[.$,;])'
    @cmd = '(wq|[acdefgijkmnpqrsw=]|\z)'
    @prmt = '(.*)'
    @format = /\A(#{@addr}(,#{@addr})?)?#{@cmd}#{@prmt}?\Z/
    @input = nil
    @result = false
    @mode = COMMAND

    loop do
      read
      eval
      print
    end
  end

  def read
    @input = STDIN.gets
  end

  def eval
    @result = nil
    if @mode == COMMAND
      if @format === @input
        case $3
        when 'q' then cmd_q
        when 'p' then @result = cmd_p(addr: $1)
        when 'a' then cmd_a(addr: $1)
        when 'd' then cmd_d(addr: $1)
        else
          @result = '? (未実装)'
        end
        @result = @current if $1 == '.' && $3 == '='
      else
        if /\A\n\Z/ === @input && @current < @buffer.size
          @current += 1
        elsif /\A\d+\z/ === @input.chomp
          @current = $&.to_i if $& && $&.int?
          @current = @buffer.size if @current > @buffer.size
          @result = @current
        else
          @result = '?'
        end
      end
    elsif @mode == INSERT
      if /\A\.\Z/ === @input
        @mode = COMMAND
      else
        @buffer.insert(@current, @input)
        @current += 1
      end
    end
  end

  def print
    puts @result unless @result.nil?
  end

  private
  # q
  def cmd_q
    exit
  end
  # p
  def cmd_p(addr: nil)
    case addr
    when /\A\d+\z/
      
    end
    if @current > @buffer.size
      @current = @buffer.size
    end
  end
  # a
  def cmd_a(addr: nil)
    @mode = INSERT
    if addr
      @current = addr.to_i if addr.int?
    end
  end
  # d
  def cmd_d(addr: nil)
    if addr
      _arr = addr.split(',')
      if _arr.first.int?
        _from = _arr.first.to_i - 1 
        _to = _arr.last.to_i - 1
        if _from < _to
          @buffer.slice!(_from, _to)
        else
          @buffer.slice!(_from)
        end
        @current = _from + 1
      end
    else
      @buffer.slice!(@current - 1)
    end
  end
end

begin
  File.open(ARGV[0]) do |file|
    Ed.new(file.read)
  end
rescue
  File.open(ARGV[0], 'w') do |file|
    Ed.new('')
  end
end
