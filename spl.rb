require 'color_echo'

CE.pickup(/expression|term|factor/, :h_yellow)
CE.pickup(/unget!|bad_token/, :h_red)

# Smiley Prompt Language
class SPL
  #  keywords in this language
  @@keywords = {
    '+' => :add,
    '-' => :sub,
    '*' => :mul,
    '/' => :div,
    '%' => :mod,
    '(' => :lpar,
    ')' => :rpar,
    'println' => :println,
    'print' => :print,
    '\'' => :s_quot,
    '"' => :w_quot,
    'INPUT' => :input,
    'OUTPUT' => :println # alias println
  }

  def initialize()
    #  insert source codes or standard input
    @code = ''
    #  memory space for variable
    @memory = {}
    @key = ''
  end

  def exec(file_name = nil)
    unless file_name
      loop {
        CE.once.ch(:h_white, :h_blue)
        print ':-) '
        @code = STDIN.gets.strip # read
        if %w(quit q exit bye).include? @code then exit end
        ex = expression # eval
        eval(ex) # print
      }
    else
      unless File.extname(file_name) == ".spl"
        error_format("ERROR : The file is not SPL file..")
        exit
      end
      File.open(file_name) do |file|
        file.each_line do |line|
          @code = line.strip
          ex = expression
          eval(ex)
        end
      end
    end
  end
private
  def get_token()
    if @code =~ /\A\s*(#{@@keywords.keys.map{|t|Regexp.escape(t)}.join('|')})/
      @code = $'
      return @@keywords[$1]
    elsif @code =~ /\A\s*([0-9.]+)/
      @code = $'
      return $1.to_f
    elsif @code =~ /\A\s*(\w+)\s*(=\s*(.*)\s*)?/ #  set variable
      unless $3.nil?
        @code = $3 + $'
      else
        @code = $'
      end
      @key = $1
      if @memory.has_key?($1.to_sym) && $3
        @memory[$1.to_sym] = expression()
      elsif !(@memory.has_key?($1.to_sym))
        @memory[$1.to_sym] = expression()
      end
      # 変数トークン
      return :variable
    elsif @code =~ /\A\s*\z/
      return nil
    end
    return :bad_token
  end

  def unget_token(token)
    if token.is_a? Numeric
      @code = token.to_s + @code
    else
      @code = @@keywords.key(token) ? @@keywords.key(token) + @code : @code
    end
  end

  def expression()
    result = term
    while true
      token = get_token
      unless token == :add or token == :sub
        unget_token token
        break
      end
      result = [token, result, term]
    end
    return result
  end

  def term()
    result = factor
    while true
      token = get_token
      unless token == :mul or token == :div
        unget_token token
        break
      end
      result = [token, result, factor]
    end
    return result
  end

  def factor()
    token = get_token
    minusflg = 1
    if token == :sub
      minusflg = -1
      token = get_token()
    end
    if token.is_a? Numeric
      return token * minusflg
    elsif token == :lpar
      result = expression()
      unless get_token == :rpar
        error_format("unexpected token")
        # raise Exception, "unexpected token"
      end
      return [:mul, minusflg, result]
    elsif token == :w_quot
      if @code =~ /\A(.*)(")/
        @code = $2 + @code
        result = $1
      end
    elsif token == :s_quot
      if @code =~ /\A(.*)(')/
        @code = $2 + @code
        result = $1
      end
    elsif token == :variable
      result = @memory[@key.to_sym]
    elsif token == :input
      input()
    elsif token == :print
      echo()
    elsif token == :println
      echo(1)
    elsif token.nil?
      # 空文字がきたら何もしない
    else
      error_format("unexpected token")
      # raise Exception, "unexpected token"
    end
  end

  def error_format(message)
    CE.once.ch(:h_white, :h_red)
    print "X-( "
    puts message
  end

  # 出力を担当 evalした結果を出力
  def echo(flg = nil)
    CE.once.ch(:h_blue)
    if flg
      if @code.empty?
        print ''
      else
        puts eval(expression())
      end
    else
      if @code.empty?
        print ''
      else
        print eval(expression())
      end
    end
  end
  # 入力を担当
  def input()
    CE.once.ch(:index27)
    print '>>> '
    value = gets.chomp
    @code = value + @code
    result = expression()
  end

  def eval(exp)
    if exp.instance_of?(Array)
      case exp[0]
      when :add
        return eval(exp[1]) + eval(exp[2])
      when :sub
        return eval(exp[1]) - eval(exp[2])
      when :mul
        return eval(exp[1]) * eval(exp[2])
      when :div
        return eval(exp[1]) / eval(exp[2])
      end
    else
      return exp
    end
  end
end

SPL.new.exec(ARGV[0])
