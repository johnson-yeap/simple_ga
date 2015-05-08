describe SimpleGa::GeneticAlgorithm do 
	subject(:search) { SimpleGa::GeneticAlgorithm::GeneticSearch.new(10, 5) }
	context "when the genetic search is initiated" do
		it "is expected that the selected array does not contain nil element" do
			search.generate_initial_population
        	selected = search.selection
        	selected.each { |s| expect(s).not_to be_nil }
		end

		it "has the right amount of populations" do
			search.generate_initial_population
			expect(search.population.length).to eql(10)
		end
	end
	context "when the worst ranked chromosomes are being replaced" do
		it "expected that the offsprings are included in the new population" do
			search.generate_initial_population
			selected =  search.selection
        	offsprings = search.reproduction selected
        	search.replace_worst_ranked offsprings
        	offsprings.each { |c| expect(search.population).to include(c)}
		end
	end
end
