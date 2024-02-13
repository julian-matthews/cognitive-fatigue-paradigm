# Computational mechanisms underlying the dynamics of physical and cognitive fatigue

###### [Julian Matthews](https://twitter.com/quined_quales), Andrea Pisauro, Mindaugas Jurgelis, Tanja Müller, [Trevor Chong](http://cogneuro.com.au/), [Matthew Apps](https://www.msn-lab.com/dr-matthew-apps)

***

[**The paper associated with this repository has been published in Cognition**](https://doi.org/10.1016/j.cognition.2023.105603)

***

> The willingness to exert effort for reward is essential but comes at the cost of fatigue. Theories suggest fatigue increases after both physical and cognitive exertion, subsequently reducing the motivation to exert effort. Yet a mechanistic understanding of how this happens on a moment-to-moment basis, and whether mechanisms are common to both mental and physical effort, is lacking. In two studies, participants reported momentary (trial-by-trial) ratings of fatigue during an effort-based decision-making task requiring either physical (grip-force) or cognitive (mental arithmetic) effort. Using a novel computational model, we show that fatigue fluctuates from trial-to-trial as a function of exerted effort and predicts subsequent choices. This mechanism was shared across the domains. Selective to the cognitive domain, committing errors also induced momentary increases in feelings of fatigue. These findings provide insight into the computations underlying the influence of effortful exertion on fatigue and motivation, in both physical and cognitive domains.

## What is this?
Here we provide **[MATLAB code](./code/experiments/)** used to conduct the cognitive fatigue experiment from our study. The code is made available under a GNUv3.0 license. 

The experiment can be initiated using the `runExp_cedm` function. Supporting functions and images are included in the `addons` folder. 

Included are the [**task instructions**](./code/experiments/addons/instructions/information_gamble_instructions.pdf) we provided to participants.

We used a **five-window slot machine with fixed odds** (50% chance of winning) to study how the opportunity to observe non-instrumental information about outcomes influences decisions to gamble. Critically, we informed participants about which slots would subsequently provide veridical information about the gamble outcome. 

![methods]

## What did you find?

Across three experiments (n=71), we found that information availability has a striking affect on behaviour; **the opportunity to receive non-instrumental information increases the propensity to gamble**. 

However, information availability does not drive behaviour in a simple, linear fashion. We used computational modeling to demonstrate that decision-making was strongly influenced by anticipatory utility. When information might provide a definitive outcome, participants were more inclined to gamble. However, when only partial information was available, participants were more inclined to reject the gamble. In fact, participants were less likely to accept gambles with partial information than a condition where no information was available at all, an effect that can be interpreted as **information avoidance**.

> The following plot illustrates the proportion of gambles accepted (**Pr(Accept)**) as a function of non-instrumental information availability (**Informative windows**). Group means for each information condition are plotted in black. Errorbars reflect within-subject standard error of the mean. Individual subject means are plotted in grey for each information condition and experiment. 

![results]

***

## You will need: 
1. [**MATLAB**](https://au.mathworks.com/products/matlab.html) and [**Psychtoolbox**](http://psychtoolbox.org/)

> Informative windows (black) display non-instrumental information that signals the outcome of the trial. Non-informative windows (white) display a random cue. All experiments had identical numbers of trials per information condition, the difference between Experiments 1 and 2 vs. Experiment 3 was the arrangement of informative windows. In Experiments 1 and 2, arrangements were randomly selected from the options in the top panel. In Experiment 3, window arrangements were composed of the options in the bottom panel. Importantly, for the partial information conditions in Experiment 3 (1 to 4 informative windows), informative windows appeared relatively early or relatively late in the trial. An equal proportion of earlier and later arrangements were used.

![arrangement]

[methods]: /figures/methods-figure.png
[results]: /figures/information-availability.png
[arrangement]: /figures/information-arrangement.png
