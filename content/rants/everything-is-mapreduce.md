title: Everything is MapReduce
date: May 26 2021
author: Maxwell G Brown

# Everything is MapReduce

![MapReduce. MapReduce everywhere.][mapreduce_everywhere]

> Product: "It's time to write some asynchronous data processing! We have files that may have records in the tens of thousands, and we need to categorize/label/process/onboard them into our system after submission from an HTTP request!"
>
> (naive) Dev: "Uuh, let's just do it in a blocking API request in a single procedural function the size of Texas?"
>
> QA: "Hey, so the processing form doesn't work for any files larger than 500kb..."
>
> PM: "I'll write a ticket to increase the file size!"

It's not the first time I've had to write a system like the above and it likely won't be the last. And it won't be the first time that a developer (naively, I feel) suggests taking an incremenetal approach to implementing it first in a blocking API call that just _does everything_. 

Very quickly though the team outgrows these implementations (probably because blocking API calls are a *Bad Idea*) and then the poor dev (or even worse, his successor!) is stuck with a ticket that says something like "increase import size from 500kb" and they find themselves trying to build Rome with a hammer & chisel.


## Let's make it right

**This rant is about MapReduce _right_?** Bear with me.

I posit that the real problem here is starting with the _wrong_ incremental approach: building that asynchronous system into the request-response cycle should be the very FIRST thing that happens here! 

- A queue with a listener that has some beefy stats? Sure okay.
- On-demand compute nodes to run tasks in long form fashion? Yeah, that might work.
- An event bus and some horizontally-scalable microservices? Sounds fun.

It doesn't ned to be entirely fleshed out, let it be an infant! Maybe you're just moving your procedural abomination downstream. Don't care, it's better now that you're not on a blocking API request.

Blocking API requests are like getting groceries during COVID: you want to deliver your message and get the hell out. Any time you spend standing in line should be making you anxious about the things happening around you.

We probably skip away from this implementation happy that we've built something cool and loosened the valve on the future featurres we have to build into our asynchronous processing system.


## Okay what next?

**Where is the MapReduce?** _Yeah yeah_ I'm getting there.

We have our nice pretty custom asynchronous data processing tooling, and it's way better than what we had before. I mean _way_ better. We can actually add features to it without worry that "rEqUeStS wILl TiMe OuT!". 

We've introduced more infrastructure overhead (after all, we _did_ solve this problem with more infrastructure). The solution is pretty custom, lets say that there's 5 steps in our flow and each step transforms and does some processing against the data. Let's pencil it out:

1. Turn XLSX rows into JSON data
2. Read JSON records for an ID to insert/update into our system
3. Read certain fields in said records for URLs of images
4. Download said images
5. Insert/update database with some light processing/transformed of values (e.g. whitespace trimming)

...and maybe to do this we have a workflow manager that manages moving between steps for us! When 1 is done, do 2. When 2 is done do 3. Do I need to do step 4? No? Skip to 5.

All the while, dropping our intermediate data somewhere so we can both pick it up at the next step or audit it after the fact.

## In case you haven't noticed yet...

**This post is about MapReduce now!**

![It's all MapReduce? Always has been.][mapreduce_always_has_been]

We did all this work just to implement a glorified MapReduce!

And we _haaaate_ unnecessary work. Why build something custom when you can worry about less and finger-point at other vendors when your stuff isn't working right?

Here's the hot-take of the day: **All data processing is just glorified MapReduce**.

Why do we even bother building our own things when we have these solutions that are hand-tailored to ripping apart and processing large swaths of data!? Would we have not done ourselves a service by starting directly with Hadoop, or a mature MapReduce-ing solution?

## I don't see it yet

It's in the name. MapReduce is two main parts:

1. **Map** initial data into keys that correspond to how we're processing the data
2. **Reduce** mapped data into "organized" data that we want to work with

...and if we want to get into specifics those two actually have other steps to talk about:

1. **Map**
   - Input
     Give the initial input
   - Split
     Split initial data into processable chunks
   - Map
     Take a chunk and key the records you want from it
2. **Reduce**
   - Shuffle
     Across the chunks, organize data into logical groups
   - Reduce
     Turn the logical groups into new data

With those enumerated, it's a lot easier to see how our problem statement fits so well into this:

1. Turn XLSX rows into JSON data
   - **Input** XLSX file
   - **Split** XLSX rows into JSON data
2. Read JSON records for an ID to insert/update into our system
   - **Map** JSON records into keys
   - **Shuffle** records into separate "Inserts" and "Update" groups
3. Read certain fields in said records for URLs of images
   (The ordered list is doing me a disservice now, since this will likely happen simultaneous to 2, but the show must go on)
   - **Map** fields with URLs
4. Download said images
   - **Reduce** URLs to new hosted location
5. Insert/update database with some light processing/transformed of values (e.g. whitespace trimming)
   - **Reduce** to new records

Did I mention that each of these steps saves the intermediate data, so we can audit between steps? 

I've built systems similar to this thrice over at my job, and whenever I take a step back to admire my handiwork I end up thinking to myself:

**Did I just build a glorified MapReduce?**

![Who are you? Rey. Rey MapReduce][rey_mapreduce]

## Confession/Disclaimer

I have no idea what I'm talking about. I've never actually used Hadoop before, nor any of the othere "MapReducers" I could find in a 3-minute google sesh (Apache Spark, Apache Storm, BigQuery, Disco).

But here I am with the confession that I've ~wasted~ spent plenty of time implementing solutions that would likely fit into the category of "Hadoop Alternative".

So, perhaps this rant was more for _me_ than any reader:

> _Maybe I should look into Hadoop or it's alternatives?_

[mapreduce_everywhere]: {static}/images/mapreduce-everywhere.jpg
[mapreduce_always_has_been]: {static}/images/mapreduce-always-has-been.jpg
[rey_mapreduce]: {static}/images/rey-mapreduce.jpg
