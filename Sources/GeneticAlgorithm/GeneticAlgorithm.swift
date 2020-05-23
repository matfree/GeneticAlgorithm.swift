//
//  GeneticAlgorithm.swift
//  GeneticAlgorithm
//
//  Created by Mathieu Morgensztern on 10/05/2020.
//  Copyright © 2020 Mathieu Morgensztern. All rights reserved.
//

import Foundation

public class GeneticAlgorithm<T> {
    var populationSize: Int
    var population: [Individual<T>] = []
    private var initializeFunction: () -> [T]
    private var fitnessFunction: ([T]) -> Double
    private var parameters: Parameters
    var generationCount: Int
    public var bestIndividual: Individual<T> {
        return population[0]
    }
    
    public init(populationSize: Int, initializeFunction: @escaping () -> [T], fitnessFunction: @escaping ([T]) -> Double) {
        self.generationCount = 0
        let newChromosome: [T] = initializeFunction()
        let crossoverPoint = Int(newChromosome.count / 2)
        self.parameters = Parameters(crossoverPoint: crossoverPoint)
        self.populationSize = populationSize
        self.initializeFunction = initializeFunction
        self.fitnessFunction = fitnessFunction
        self.initializeIndividuals()
    }
    
    public init(populationSize: Int, initializeFunction: @escaping () -> [T], fitnessFunction: @escaping ([T]) -> Double, parameters: Parameters) {
        self.generationCount = 0
        self.parameters = parameters
        self.populationSize = populationSize
        self.initializeFunction = initializeFunction
        self.fitnessFunction = fitnessFunction
        self.initializeIndividuals()
    }
    
    private func initializeIndividuals() {
        population = []
        for _ in 1...populationSize {
            let chromosome: [T] = initializeFunction()
            let individual = Individual<T>(chromosome)
            population.append(individual)
        }
        population = fitness(population)
    }
    
    public func generate(generationCount: Int, fitnessTarget: Double?=nil) {
        for _ in 1...generationCount {
            createNewGeneration()
            if let target = fitnessTarget {
                if fitnessTargetReached(target) {
                    return
                }
            }
        }
    }
    
    private func fitnessTargetReached(_ target: Double) -> Bool {
        return bestIndividual.fitness == target
    }
    
    private func createNewGeneration() {
        var newIndividuals: [Individual<T>] = []
        let parents = selection()
        newIndividuals = crossover(parents)
        newIndividuals = mutation(newIndividuals)
        newIndividuals = fitness(newIndividuals)
        updatePopulation(parents: parents, newIndividuals: newIndividuals)
        scaleFitness()
        generationCount += 1
    }
    
    private func fitness(_ individuals: [Individual<T>]) -> [Individual<T>] {
        for individual in individuals {
            individual.fitness = fitnessFunction(individual.chromosome)
        }
        return individuals
    }
    
    private func scaleFitness() {
        switch parameters.fitnessScale {
        case .rough:
            return
        case .windowing:
            let minFitness = population[-1].fitness
            for individual in population {
                individual.fitness -= minFitness
            }
        case .exponential:
            for individual in population {
                individual.fitness = sqrt(individual.fitness)
            }
        case .linear:
            var i: Int = 0
            for individual in population {
                individual.fitness = Double(population.count - i)
                i -= 1;
            }
        }
    }
    
    private func selection() -> [Individual<T>] {
        let parentCount = max(Int(Double(populationSize) * parameters.parentProportion), 2)
        return Array(population.prefix(parentCount))
    }
    
    private func crossover(_ parents: [Individual<T>]) -> [Individual<T>] {
        var individuals: [Individual<T>] = []
        for i in 0...parents.count - 2 {
            var newChromosome: [T] = []
            for j in 0...parameters.crossoverPointIndex {
                newChromosome.append(parents[i].chromosome[j])
            }
            for j in (parameters.crossoverPointIndex + 1)..<parents[i + 1].geneCount {
                newChromosome.append(parents[i + 1].chromosome[j])
            }
            individuals.append(Individual<T>(newChromosome))
        }
        return individuals
    }
    
    private func mutation(_ individuals: [Individual<T>]) -> [Individual<T>] {
        for i in 0...individuals.count - 1 {
            if Double.random(in: 0...1) < parameters.chromosomeMutationProbability {
                let newChromosome: [T] = initializeFunction()
                for j in 0..<individuals[i].geneCount {
                    if Double.random(in: 0...1) < parameters.geneMutationProbability {
                        individuals[i].chromosome[j] = newChromosome[j]
                    }
                }
            }
        }
        return individuals
    }
    
    /// Keeps non parents individuals
    private func updatePopulation(_ newIndividuals: [Individual<T>]) {
        for _ in 1...newIndividuals.count {
            population.removeLast()
        }
        population += newIndividuals
        population.sort(by: { $0.fitness > $1.fitness })
    }
    
    /// Generates new individuals to raplace non parents
    private func updatePopulation(parents: [Individual<T>], newIndividuals: [Individual<T>]) {
        population = []
        population += parents
        population += newIndividuals
        for _ in 1...populationSize - population.count {
            let chromosome: [T] = initializeFunction()
            let individual = Individual<T>(chromosome)
            individual.fitness = fitnessFunction(individual.chromosome)
            population.append(individual)
        }
        population.sort(by: { $0.fitness > $1.fitness })
    }
    
    public enum FitnessScale {
        case rough
            /// Rough fitness
        case windowing
            /// Zero based distribution
        case exponential
            /// Square root to reduce the influence of the strongest individuals
        case linear
            /// Fitness are linearized: same distance between all fitness
    }
    
    public class Individual<T> {
        var chromosome: [T] = []
        var fitness: Double = -Double.infinity
        var geneCount: Int {
            return chromosome.count
        }
        
        init(_ chromosome: [T]) {
            self.chromosome = chromosome
        }
    }
    
    public class Parameters {
        var fitnessScale: FitnessScale
        var parentProportion: Double
        var crossoverPointIndex: Int
        var chromosomeMutationProbability: Double
        var geneMutationProbability: Double
        
        public init(crossoverPoint: Int) {
            fitnessScale = FitnessScale.rough
            parentProportion = 0.2
            self.crossoverPointIndex = crossoverPoint - 1
            chromosomeMutationProbability = 0.3
            geneMutationProbability = 0.3
        }
        
        public init(fitnessScale: FitnessScale, parentProportion: Double, crossoverPoint: Int, chromosomeMutationProbability: Double, geneMutationProbability: Double) {
            self.fitnessScale = fitnessScale
            self.parentProportion = parentProportion
            self.crossoverPointIndex = crossoverPoint - 1
            self.chromosomeMutationProbability = chromosomeMutationProbability
            self.geneMutationProbability = geneMutationProbability
        }
    }
}
