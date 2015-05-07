# Author::    Johnson Yeap
# License::   MPL 1.1
# Project::   Academic Planner - Pointa
# Url::       http://pointa.herokuapp.com/

require "simple_ga/version"
require "simple_ga/hello"

module SimpleGa
  # The GeneticAlgorithm module implements the GeneticSearch and Chromosome 
  # classes. The GeneticSearch class performs a stochastic search 
  # of the solution of a given problem.
  # 
  # Both the GeneticSearch and Chromosome are "problem specific". SimpleGa built-in 
  # Chromosome class and GeneticSearch class were designed to model the
  # probability distribution problem. If you want to solve other type of problem, 
  # you will have to modify both of the classes, by overwriting its run, uniquify, 
  # fitness, reproduce, and mutate functions, to model your specific problem.
  module GeneticAlgorithm

    #  This class is used to automatically:
    #   
    #   1. Choose initial population
    #   2. Evaluate the fitness of each individual in the population
    #   3. Repeat
    #         1. Select best-ranking individuals to reproduce
    #         2. Breed new generation through crossover and mutation (genetic operations) 
    #            and give birth to offspring
    #         3. Evaluate the individual fitnesses of the offspring
    #         4. Replace worst ranked part of population with offspring
    #   4. Until termination
    class GeneticSearch

      attr_accessor :population

      def initialize(initial_population_size, generations)
        @population_size = initial_population_size
        @max_generation = generations
        @generation = 0
      end

      def run
        generate_initial_population       		                    
        search_space = []   					# All possible solutions to the problem.                            
        @max_generation.times do
          selected_to_breed = selection     	# Evaluates current population.           
          selected_to_breed.each do |chromosome|
            search_space << chromosome.data.dup
          end
          offsprings = reproduction selected_to_breed	 
          replace_worst_ranked offsprings
        end
        unique_solutions = uniquify search_space
        
        return best_chromosome
      end

      def uniquify(search_space)
        unique_search_space = search_space.uniq
        # Turns every unselected courses data into nil
        unique_search_space.each do |c|
          0.step(c.data.length-1, 2) do |index|         # Odd index
            if c[index] == 0
              c[index] = nil
              c[index+1] = nil
            end
          end
        end
        unique_solutions = unique_search_space.uniq

        return unique_solutions
      end

      def generate_initial_population
       @population = []
       @population_size.times do
         population << Chromosome.seed
       end
      end

      # Select best-ranking individuals to reproduce
      # 
      # Selection is the stage of a genetic algorithm in which individual 
      # genomes are chosen from a population for later breeding. 
      # There are several generic selection algorithms, such as 
      # tournament selection and roulette wheel selection. We implemented the
      # latest.
      # 
      # Steps:
      # 
      # 1. The fitness function is evaluated for each individual, providing fitness values
      # 2. The population is sorted by descending fitness values.
      # 3. The fitness values are then normalized. (Highest fitness gets 1, lowest fitness gets 0). The normalized value is stored in the "normalized_fitness" attribute of the chromosomes.
      # 4. A random number R is chosen. R is between 0 and the accumulated normalized value (all the normalized fitness values added togheter).
      # 5. The selected individual is the first one whose accumulated normalized value (its is normalized value plus the normalized values of the chromosomes prior it) greater than R.
      # 6. We repeat steps 4 and 5, 2/3 times the population size.    
      def selection
        @population.sort! { |a, b| b.fitness <=> a.fitness}
        best_fitness = @population[0].fitness
        worst_fitness = @population.last.fitness
        acum_fitness = 0
        if best_fitness-worst_fitness > 0
        @population.each do |chromosome| 
          chromosome.normalized_fitness = (chromosome.fitness - worst_fitness)/(best_fitness-worst_fitness)
          acum_fitness += chromosome.normalized_fitness
        end
        else
          @population.each { |chromosome| chromosome.normalized_fitness = 1}  
        end
        selected_to_breed = []
        ((2*@population_size)/3).times do 
          selected_to_breed << select_random_individual(acum_fitness)
        end

        selected_to_breed
      end

      # We combine each pair of selected chromosome using the method 
      # Chromosome.reproduce
      #
      # The reproduction will also call the Chromosome.mutate method with 
      # each member of the population. You should implement Chromosome.mutate
      # to only change (mutate) randomly. E.g. You could effectivly change the
      # chromosome only if 
      #     rand < ((1 - chromosome.normalized_fitness) * 0.4)
      def reproduction(selected_to_breed)
        offsprings = []
        0.upto(selected_to_breed.length/2-1) do |i|
          offsprings << Chromosome.reproduce(selected_to_breed[2*i], selected_to_breed[2*i+1])
        end
        @population.each do |individual|
          Chromosome.mutate(individual)
        end
        return offsprings
      end

      # Replace worst ranked part of population with new offsprings.
      def replace_worst_ranked(offsprings)
        size = offsprings.length
        # Replacing from the back because the population has been sorted accordingly. 
        @population = @population [0..((-1*size)-1)] + offsprings
      end

      # Select the best chromosome in the population.
      def best_chromosome
        the_best = @population[0]
        @population.each do |chromosome|
          the_best = chromosome if chromosome.fitness > the_best.fitness
          # chromosome.fitness > the_best.fitness will produce the first best chromosome.
          # chromosome.fitness >= the_best.fitness will product the last best chromosome.
          # Hence, it is not a matter of concern unless the risk analysis is important. 
          # e.g. high risk approach and low risk approach.
        end
        return the_best
      end

      private 
      def select_random_individual(acum_fitness)
        select_random_target = acum_fitness * rand
        local_acum = 0
        @population.each do |chromosome|
          local_acum += chromosome.normalized_fitness
          return chromosome if local_acum >= select_random_target
        end
      end
    end # end/GeneticSearch

    # A Chromosome is a representation of an individual solution for a specific 
    # problem. You will have to redifine the Chromosome representation for each
    # particular problem, along with its fitness, mutate, reproduce, and seed methods.
    class Chromosome

      attr_accessor :data
      attr_accessor :normalized_fitness

      def initialize(data) # Chromosome.new
        @data = data
      end

      # The fitness method quantifies the optimality of a solution 
      # (that is, a chromosome) in a genetic algorithm so that that particular 
      # chromosome may be ranked against all the other chromosomes. 
      # 
      # Optimal chromosomes, or at least chromosomes which are more optimal, 
      # are allowed to breed and mix their datasets by any of several techniques, 
      # producing a new generation that will (hopefully) be even better.
      def fitness
        return @fitness if @fitness

        # Current state inputs to be retrieved from the database.
        credits = [2,3,3,3,5,2,4,4,4,4,3]
        old_gpa = 58 
        old_total_credits = 16
        min_credits = 16
        max_credits = 20
        target_cgpa ||= 3.7

        courses, grades, points = [], [], []
        # Split the chromosome into 2.
        0.step(@data.length-1, 2) do |j|
          courses << @data[j]
          grades << @data[j+1]
        end

        total_credits = ([courses, credits].transpose.map {|x| x.inject(:*)}).inject{|sum,x| sum + x }
        new_total_credits = old_total_credits + total_credits

        grades.each do |grade|
          case grade
            when 1
              points << 4.00
            when 2
              points << 3.70
            when 3
              points << 3.30
            when 4
              points << 3.00
            when 5
              points << 2.70
            when 6
              points << 2.30
            when 7
              points << 2.00
          end
        end

        gpa = (([credits, courses, points].transpose.map {|x| x.inject(:*)}).inject{|sum,x| sum + x }).round(2)
        new_gpa = old_gpa + gpa
        cgpa = (new_gpa/new_total_credits).round(2)

        # Core constraints.
        # Elites own a high fitness value.
        # The higher the fitness value, the higher the chance of being selected. 
        if total_credits <= max_credits && total_credits >= min_credits && cgpa >= target_cgpa
            @fitness = cgpa
        # This chromosome doesn't satisfy the important constraints 
        # e.g. within the range of min_credits and max_credits
        # should be discarded.

        # Perhaps, we should add cases that statisfy one of the constraints
        # 1. credit hours + cgpa
        # 2. credit hours
        else 
            # Negative cgpa value will allow the invalid chromosome to be considered.
            # However, surprisingly the solutions suggested are more consistent and 
            # diverse.
            @fitness = 0
        end
        return @fitness
      end
        
      # Mutation method is used to maintain genetic diversity from one 
      # generation of a population of chromosomes to the next. It is analogous 
      # to biological mutation. 
      # 
      # The purpose of mutation in GAs is to allow the 
      # algorithm to avoid local minima by preventing the population of 
      # chromosomes from becoming too similar to each other, thus slowing or even 
      # stopping evolution.
      # 
      # Callling the mutate function will "probably" slightly change a chromosome
      # randomly. 

      def self.mutate(chromosome)
        if chromosome.normalized_fitness && rand < ((1 - chromosome.normalized_fitness) * 0.4)
            courses, grades = [], []
            data = chromosome.data

            # Split the chromosome into 2.
            0.step(data.length-1, 2) do |j|
              courses << data[j]
              grades << data[j+1]
            end

            p1 = (rand * courses.length-1).ceil
            courses[p1] = rand(2)
            p2 = (rand * grades.length-1).ceil
            grades[p2] = (1 + rand(6))

            # Recombine the chromosome.
            # [0,1,2,3,4,5,6,7,8,9,10]
            0.upto(courses.length-1) do |j|
              even_index = j * 2
              odd_index =  even_index + 1
              data[even_index] = courses[j]
              data[odd_index] = grades[j]
            end

            chromosome.data = data
            @fitness = nil
        end
      end
      
      # Reproduction method is used to combine two chromosomes (solutions) into 
      # a single new chromosome. There are several ways to
      # combine two chromosomes: One-point crossover, Two-point crossover,
      # "Cut and splice", edge recombination, and more. 
      # 
      # The method is usually dependant of the problem domain.
      # In this case, we have implemented one-point crossover, which is the 
      # most used reproduction algorithm for the estimation of probablity distribution.

      # Chromosome a and b might be the same.
      # [NOTE] Why is chromosome a the same as chromosome b?
      def self.reproduce(a, b)
        # We know that (a.data.length == b.data.length) must be always true.
        chromosomeLength = a.data.length
        aCourses, bCourses, aGrades, bGrades = [], [], [], []    

        # Split the chromosome into 2.
        0.step(chromosomeLength-1, 2) do |index|
          next_index = index + 1
          aCourses << a.data[index]
          aGrades << a.data[next_index]
          bCourses << b.data[index]
          bGrades << b.data[next_index]
        end

        # One-point crossover
        # We know that (aCourses.length == aGrades.length) must be always true.
        # However, we want to cut and cross at different points for the 
        # corresponding course and grade array.
        # Avoid slice(0,0) or slice (11,11). It brings no changes.
        course_Xpoint = rand(aCourses.length-1) + 1 
        grade_Xpoint = rand(aGrades.length-1) + 1
        new_Courses = aCourses.slice(0, course_Xpoint) + bCourses.slice(course_Xpoint, aCourses.length)
        new_Grades = aGrades.slice(0, grade_Xpoint) + bGrades.slice(grade_Xpoint, aGrades.length)
        
        spawn = []
        # We know that (new_Courses.length == new_Grades.length) must be always true.
        0.upto(new_Courses.length-1) do |i|
          spawn << new_Courses[i]
          spawn << new_Grades[i]
        end

        return Chromosome.new(spawn)
      end

      # Initializes an individual solution (chromosome) for the initial 
      # population. Usually the chromosome is generated randomly, but you can 
      # use some problem domain knowledge, to generate a (probably) better 
      # initial solution.

      def self.seed
        # Current state inputs to be retrieved from the database.
        ncourse = 11
        seed = []

        1.step(ncourse*2, 2) do |j|
          seed << rand(2)
          seed << (1 + rand(6))
        end
        return Chromosome.new(seed)
      end
    end # end/Chromosome
  end # end/GeneticAlgorithm
end # end/SimpleGa
