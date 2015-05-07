# describe "test one" do 
# 	context "first test" do
# 		it "is a test" do
# 			expect(1).to eql(1)
# 		end
# 	end
# end

require "simple_ga"

describe Chromosome do 
	context "first test" do
		it "is a test" do
			@hello = Hello.new
			expect(@hello.pow(3,2)).to eql(9)
		end
	end
end

# describe Chromosome do 
# 	context "when a new chromosome is create" do
# 		it "has a length of an even number" do
# 			chromosome = Chromosome.seed
# 			expect(chromosome.data.length % 2).to eql(0)
# 		end
# 	end
# end
