describe SimpleGa::GeneticAlgorithm::Chromosome do 	
	available_courses = [["Ethnic Relations",2],["Principles of Information Systems",3],["Computer Systems & Organization",3],["Computing Mathematics I",3],["Programming I",5],["Islamic And Asian Civilization",2],["Operating Systems",4],["Human Computer Interaction",4],["Software Project Management",4],["Programming for Web Engineering",4],["Software Requirements Engineering",3]]
	SimpleGa::GeneticAlgorithm::Chromosome.set_params(available_courses, 58, 16)

	subject { SimpleGa::GeneticAlgorithm::Chromosome.seed }
	subject(:c1) { SimpleGa::GeneticAlgorithm::Chromosome.new([0, 1, 1, 2, 0, 1, 1, 1, 0, 3, 1, 1, 0, 3, 1, 1, 1, 2, 0, 6, 1, 2]) }
	subject(:c2) { SimpleGa::GeneticAlgorithm::Chromosome.new([0, 2, 0, 6, 0, 1, 0, 1, 0, 3, 0, 4, 1, 2, 0, 4, 1, 3, 1, 4, 1, 5]) }

	context "when a new chromosome is created" do
		it "has a length of an even number" do
			expect(subject.data.length % 2).to eql(0)
		end

		it "has a positive or zero fitness value" do
			expect(subject.fitness).to be >= 0
		end
	end

	context "when two distinctive chromosomes crossover" do
		it "reproduces a new distinctive chromosome" do
        	c3 = SimpleGa::GeneticAlgorithm::Chromosome.reproduce(c1, c2)
        	expect(c3.data).not_to eql(c1.data && c2.data)
		end

		it "reproduces a new chromosome with the same data length" do
        	c3 = SimpleGa::GeneticAlgorithm::Chromosome.reproduce(c1, c2)
        	expect(c3.data.length).to eql(c1.data.length && c2.data.length)
		end
	end
end