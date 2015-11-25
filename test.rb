pattern = /.*#{ARGV[0]}.*/ # パターンを取得
filename = ARGV[1] # ファイル名を取得

File.open(filename) do |file|
	puts file.read.scan(pattern)
end