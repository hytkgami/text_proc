begin
pattern = Regexp.new ARGV[0] # パターンを取得
rescue => e
	puts "egrep: parentheses not balanced"
	# puts e.message
end

filename = ARGV[1] # ファイル名を取得
file = open(filename)
file.each {|line|
	# 単語ごとに分割
	line.split.map {|word|
		puts word if word =~ pattern
	}
}
file.close
