# GeneticAlgorithm.swift

This library implements Genetic Algorithm as a Swift Package.

A genetic algorithm is a search heuristic that is inspired by Charles Darwin's theory of natural evolution. This algorithm reflects the process of natural selection where the fittest individuals are selected for reproduction in order to produce offspring of the next generation.

## Functionality

Create your own initialization and fitness function, using any variables (genes) type and pass them to the GeneticAlgorithm class initialization function.

## Example

Here is an example showing how to maximize `y` in the function `y=4*w1-2*w2+7*w3+5*w4+11*w5+1*w6` by slecting the paramters `w1...w6`.
The `w` parameters represent de genes of the chromosome of each individual.
The values for the `w` parameters can take continuous values between -4 and 4.

Initialization function:

```swift
func initialize() -> [Double] {
    var w: [Double] = []
    for _ in 1...6 {
        w.append(Double.random(in: -4...4))
    }
    return w
}
```

Fitnes function:

```swift
func fitness(w: [Double]) -> Double {
    let x: [Int]  = [4, -2, 7, 5, 11, 1]
    var y: Double = 0
    for i in 0..<x.count {
        y += Double(x[i]) * w[i]
    }
    return y
}
```
Defining the parameters (optional):

```swift
let param = GeneticAlgorithm<Int>.Parameters(fitnessScale: .rough, parentProportion: 0.25, crossoverPoint: 3, chromosomeMutationProbability: 0.3, geneMutationProbability: 0.3)
```

Instantiating the class:

```swift
let ga = GeneticAlgorithm(populationSize: 50, initializeFunction: initializeGrid, fitnessFunction: fitnessGrid, parameters: param)
```

Display the initial fitness of the best individual:

```swift
print(ga.bestIndividual.fitness)
print(ga.bestIndividual.chromosome)
```

Creates this output:

```
-18.96263919925819
[2.4968362354458975, 1.8826652892465043, -2.7221735545814294, -2.578491311636144, 0.8534734684523002, -2.6251902752733525]
```

Generate the generations of individualts (here 300 generations):

```swift
ga.generate(generationCount: 300)
```

Display the resulting fitness of the best individual:

```swift
print(ga.bestIndividual.fitness)
print(ga.bestIndividual.chromosome)
```

Creates this output:

```
114.56522240342939
[3.854539740025537, -3.7085929472351538, 3.9998586679581383, 3.9130955637866, 3.6588478098121415, 3.918063146283397]
```
