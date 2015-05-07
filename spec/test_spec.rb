# describe "test one" do 
# 	context "first test" do
# 		it "is a test" do
# 			expect(1).to eql(1)
# 		end
# 	end
# end

describe Hello do 
	context "first test" do
		it "is a test" do
			@hello = Hello.new
			@hello.hello
		end
	end
end