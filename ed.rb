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
          @result = @current
        elsif /\A\d+\z/ === @input.chomp
          @current = get_current(index: $&.to_i)
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
    _result = []
    case addr
    when /\A\d+\Z/
      _from = addr.to_i
      _to = _from
    when /\A\d+,\d+\Z/
      _tmp = addr.split(',')
      _from = _tmp.first.to_i
      _to = _tmp.last.to_i
    when /\A,,,\Z/
      _from = 1
      _to = @buffer.size
    when /\A\d+,\$\Z/
      _from = addr.split.first.to_i
      _to = @buffer.size
    when nil
      _from = @current
      _to = _from
    else
      _from = 1
      _to = @buffer.size
    end
    _from = 1 if _from < 1
    _to = @buffer.size if _to > @buffer.size
    @current = _to
    _result + @buffer[(_from-1)..(_to-1)]
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
    case addr
    when /\A\d+\Z/
      _from = addr.to_i
      _to = _from
    when /\A\d+,\d+\Z/
      _tmp = addr.split(',')
      _from = _tmp.first.to_i
      _to = _tmp.last.to_i
    when /\A,,,\Z/
      _from = 1
      _to = @buffer.size
    when nil
      _from = @current
      _to = _from
    else
      _from = 1
      _to = @buffer.size
    end
    _from = 1 if _from < 1
    @buffer.slice!((_from - 1)..(_to - 1))
    @current = get_current(index: _to)
  end

  def get_current(index: 0)
    if index > @buffer.size
      @buffer.size
    else
      index
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
