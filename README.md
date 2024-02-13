# Computational mechanisms underlying the dynamics of physical and cognitive fatigue

###### [Julian Matthews](https://twitter.com/quined_quales), [Andrea Pisauro](https://twitter.com/AndreaPisauro), [Mindaugas Jurgelis](https://twitter.com/MKJurgelis), [Tanja Müller](https://twitter.com/tm_brainscience), [Eliana Vassena](https://twitter.com/ElianaVassena), [Trevor Chong](http://cogneuro.com.au/), [Matthew Apps](https://www.msn-lab.com/dr-matthew-apps)

***

[**The paper associated with this repository has been published in Cognition**](https://doi.org/10.1016/j.cognition.2023.105603)

***

> The willingness to exert effort for reward is essential but comes at the cost of fatigue. Theories suggest fatigue increases after both physical and cognitive exertion, subsequently reducing the motivation to exert effort. Yet a mechanistic understanding of how this happens on a moment-to-moment basis, and whether mechanisms are common to both mental and physical effort, is lacking. In two studies, participants reported momentary (trial-by-trial) ratings of fatigue during an effort-based decision-making task requiring either physical (grip-force) or cognitive (mental arithmetic) effort. Using a novel computational model, we show that fatigue fluctuates from trial-to-trial as a function of exerted effort and predicts subsequent choices. This mechanism was shared across the domains. Selective to the cognitive domain, committing errors also induced momentary increases in feelings of fatigue. These findings provide insight into the computations underlying the influence of effortful exertion on fatigue and motivation, in both physical and cognitive domains.

## What is this?
Here we provide **[MATLAB code](./code/)** used to conduct the cognitive fatigue experiment from our study. The code is made available under a GNUv3.0 license. 

The experiment can be initiated using the **`runExp_cedmt`** function. Supporting functions and images are included in the **`addons`** folder together with the [**task instructions**](./code/addons/instructions/cognitive_fatigue_instructions.pdf). 

Mathematical operators are drawn from [**`fatigue_stimuli.csv`**](./code/addons/fatigue_stimuli.csv). This file includes 14 variables:
- `ID`= Operation number
- `EffortDegree`= Number from 0 or 1:5
- `Reward`= Value from 1 or 2:2:10
- `Num1` through `Num6`= Operation values either +ve or -ve
- `CorrectResult`= Response that is correct
- `WrongResult1` and `WrongResult2`= Responses that are incorrect
- `Difference1` and `Difference2`= The difference between the correct & incorrect responses

## You will need: 
1. [**MATLAB**](https://au.mathworks.com/products/matlab.html)
2. [**Psychtoolbox**](http://psychtoolbox.org/)

***

## Method
We used a **cognitive effort decision making task** to study the value of exerting cognitive effort for reward. 

Cognitive effort was operationalised using **mental arithmetic**. Six operators appeared in rapid succession which the participant had to sum in their head. Then, they had 1.5 seconds to select the correct response from three alternatives. The level of cognitive effort was manipulated by the choice of operators and numerical proximity of the incorrect alternatives to the correct response.

> Participants chose between a fixed _rest_ offer for 1 credit and variable _work_ offers that paired different levels of effort with different rewards. In this example, the participant chooses a work offer that requires the successful exertion of intermediate effort (level 3) for 6 credits in reward. After working or resting, participants rated their fatigue on a 0–100 point scale. Finally, the outcome of the trial was revealed.

![methods]

## Fatigue
Critically, we contrasted decisions to exert effort in two contexts. 

1. In the **Pre-task**, offers involved a wide variety of effort and reward conditions but participants were required to complete the chosen offer (i.e., exert effort) on a random subset of decisions only. Thus, decisions to exert effort were performed in the context of minimal fatigue. 
2. In the **Main task**, the best offers appeared (i.e., higher rewards for lower effort) but participants were required to complete the chosen offer on every trial. No breaks were provided so the only way for participants to recover from mental exertion was to select the _rest_ offer. Thus, decisions to exert effort were performed in the context of increasing fatigue. 

> In the **Pre-task**, work offers included 5 levels of effort and 5 levels of reward. In the **Main task**, work offers paired the 3 highest levels of reward with the 3 lowest levels of effort.

![conditions]

> Decisions not to work (i.e., **rest**) required the participant to respond to a fixed mathematical operation (a sum of zeros) where the answer (zero) was known in advance.

![rest]

[methods]: /figures/cognitive_paradigm.png
[conditions]: /figures/effort_conditions.png
[rest]: /figures/cognitive_rest.png
