title: SQS to Lambda Makes Me Feel Bad
date: May 27 2021
author: Maxwell G Brown

# SQS to Lambda Makes Me Feel Bad (& Misery Loves Company)

I myself remember a time (pre mid-2018) when AWS did not support SQS as a Lambda trigger. For the life of me I cannot find any recollection of this on the internet--it seems as the deep state has entirely scrubbed the internet of frustrated AWS users asking "why in god's name can't I go from SQS -> Lambda?!?!" (and, I myself used to be one of them).

![If an item doesn't appear in our records, it doesn't exist][not_in_the_archives]

Today, while searching for this exact case I find nothing but absolute celebration that our lord god AWS itself has delivered upon to us **[SQS as a Lambda trigger](https://aws.amazon.com/blogs/aws/aws-lambda-adds-amazon-simple-queue-service-to-supported-event-sources/)**. _He is risen!_

## Okay so what's the problem?

Again, I cannot find **any** mention on AWS's stance on SQS -> Lambda triggers pre June-2018.

But everything in my memory tells me the reason it took ~4 years to integrate their very first service into their next-gen compute platform was not because nobody wanted it, but because _they disagreed with the entire premise of it_.

![It ought to be here... but it isn't][aught_to_isnt]

Page and page of AWS Helpdesk questions (the public ones, I don't remember what they're called and I don't care to hunt it down) asking "HoW cAn I gEt SQS tO tRiGgEr A lAmBdA?" and AWS saying "please stop trying you're doing it wrong". Today, I can't find a single one of them, but I remember it deep in my soul because _I was asking the same question and was disatisfied with the answer_!

What I remember is their reasoning being something to the effect of:

> SQS is a queueing mechanism for polling services to receive messages in an asynchronous fashion.
> AWS Lambda is a computing service built to accept triggers, run, then terminate.
> If you want to communicate asynchronously with AWS Lambda, _why don't you just send the message directly to the lambda?_

I can hear me in 2017 right now: "Gah! I don't _want_ to trigger a lambda directly because I don't want to be tightly coupled to it!"

...and maybe there's some merit to that. The whole purpose of queues is to allow you to throttle overflow on requests while the consumers can handle them at their leisure, so why should whomst is sending the message care about who consumes it? This is probably the only argument and reasoning I'll buy for Lambdas as a queue consumer. That and being to lazy to want to spin up real infrastructure (which I am certainly guilty of)

## Why are we throtling small compuation nodes?

Lambda was not made to be big. It's whole purpose is to be a small computational node that executes quickly and scales near-infinittely horizontally.

The hard part to scaling horizontally is already being performed by whomever is splitting the messages into batches for the queue anyways! 

Not to mention, Lambda has a feature for running asynchronously (as opposed to a request-response cycle) so you don't have to wait for a response.

Oh, did I mention that if trigger events fail to be processed or overflow past your throttle when you reach your lambda limit, _you can configure a Dead-Letter Queue to catch them?_. 

### Also, are we _really_ decoupled?

Not to mention, you're publishing a message to a queue, a message that fits into the queue that you know is going to be picked up by a service expecting it to be in _some shape_.

If you published that message directly to Lambda you'd get effectively the same result from the producer perspective!

The only real benefit you're getting is offloading the computation of _something_, and you don't care what it is. If that's what we're going for, I posit there are better ways to do that.

## What if there was something... better

![I want you to join me][join_me]

Okay so I don't think you should go from SQS -> Lambda. What then, is that it?

Replacing the good-ol' push/pull model is the (imo much more flexible) pub/sub model.

Instead of connecting your services together with queues, we should first consider an **Event Bus**!

In this world, the service lives in an ecosystem of other services all connected by messages flowing through an Event Bus. Subscribe to the ones you like, and process them there! Your service is already supposed to handle events idempotently if you're considering using a service in the first place, so you've already handled the hard part.

The prerequisites to get Event Bus ready are already so similar to getting it queue ready:

* You should be handling events idempotently
* You should be able to scale horizontally to handle load (which, I guess isn't necessarily required for queue consumers, but if you want messages to be handled timely...)

...and you get the ability to do _so much more_:

* Listen to multiple different types of events, instead of just the ones you couple to the queue
* Publish messages _back_ to the event bus for other services to consume
* Decouple other services from producing to _your queue_ and instead couple them to the Event Bus enviornment (biome?) where they can talk to the rest of the animal kingdom!
* (I could go on and on about what I think Event Busses enable, but these two are the most pertinant for now)

Queues still serve a purpose: throttling expensive asynchronous operations! But shoe-horning them into being glorified message brokers is doing everybody a disservice, and is something SNS _was literally made to do_.

## In Conclusion...

If you're using Lambdas as SQS Queue consumers then maybe you're doing it wrong.


[not_in_the_archives]: {static}/images/not-in-the-archives.png
[aught_to_isnt]: {static}/images/aught-to-isnt.png
[join_me]: {static}/images/join-me.gif
