import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        inspirationCost : Nat;
        talesCost : Nat;
        requestCost : Nat;
    };

    public type Choice = {
        #seekInspiration;
        #listenTales;
        #requestSong;
        #leave;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("seekInspiration") ? #seekInspiration;
            case ("listenTales") ? #listenTales;
            case ("requestSong") ? #requestSong;
            case ("leave") ? #leave;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#seekInspiration or #listenTales or #leave) null;
            case (#requestSong) ? #trait(#clever);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#seekInspiration) "Seek inspiration from the bard. Warning: May cause spontaneous poetry.";
            case (#listenTales) "Listen to the bard's tales. 50% history, 50% gossip, 100% embellished.";
            case (#requestSong) "Request a specific song. Hope you like 'Wonderwall'.";
            case (#leave) "Leave the bard. Your ears could use a break anyway.";
        };
    };

    public func getTitle() : Text {
        "Travelling Bard";
    };

    public func getDescription() : Text = "You encounter a bard whose lute is suspiciously in tune for someone who's been on the road.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "seekInspiration";
                description = getChoiceDescription(#seekInspiration);
            },
            {
                id = "listenTales";
                description = getChoiceDescription(#listenTales);
            },
            {
                id = "requestSong";
                description = getChoiceDescription(#requestSong);
            },
            { id = "leave"; description = getChoiceDescription(#leave) },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        data : Data,
        choiceOrUndecided : ?Choice,
    ) {
        switch (choiceOrUndecided) {
            case (null) {
                outcomeProcessor.log("You stand there, caught between fight or flight as the bard clears his throat.");
            };
            case (?choice) {
                switch (choice) {
                    case (#seekInspiration) {
                        if (outcomeProcessor.removeGold(data.inspirationCost)) {
                            if (prng.nextRatio(3, 5)) {
                                outcomeProcessor.log("The bard's words stir your soul. You feel more... magical. Or was that just indigestion?");
                                outcomeProcessor.upgradeStat(#magic, 1);
                            } else {
                                outcomeProcessor.log("The bard's inspiration misses the mark. You now know way too much about the mating habits of geese.");
                            };
                        } else {
                            outcomeProcessor.log("The bard raises an eyebrow at your empty pockets. Inspiration doesn't pay for itself, you know.");
                        };
                    };
                    case (#listenTales) {
                        if (outcomeProcessor.removeGold(data.talesCost)) {
                            if (prng.nextRatio(1, 2)) {
                                outcomeProcessor.log("The bard's tales of heroic deeds fill you with courage. You feel stronger, or at least less likely to run from a fight.");
                                outcomeProcessor.upgradeStat(#attack, 1);
                            } else {
                                outcomeProcessor.log("The bard's stories of cunning heroes sharpen your wits. You're now 30% more likely to spot a bad deal... like this one.");
                                outcomeProcessor.upgradeStat(#defense, 1);
                            };
                        } else {
                            outcomeProcessor.log("The bard stops mid-sentence, looking expectantly at your coin purse. Seems this tale has a cover charge.");
                        };
                    };
                    case (#requestSong) {
                        if (outcomeProcessor.removeGold(data.requestCost)) {
                            if (prng.nextRatio(2, 3)) {
                                outcomeProcessor.log("The bard plays your request with surprising skill. You receive a magical token of appreciation from the universe.");
                                ignore outcomeProcessor.addItem(#fairyCharm); // TODO already have item?
                            } else {
                                outcomeProcessor.log("The bard butchers your request so badly, nearby plants wilt. You're pretty sure you've just lost brain cells.");
                            };
                        } else {
                            outcomeProcessor.log("The bard strums a chord that sounds suspiciously like a cash register. No gold, no song.");
                        };
                    };
                    case (#leave) {
                        outcomeProcessor.log("You leave the bard, humming a tune that will be stuck in your head for days. Thanks a lot.");
                    };
                };
            };
        };
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#seekInspiration) 0;
            case (#listenTales) 1;
            case (#requestSong) 2;
            case (#leave) 3;
        };
    };

    public func generate(prng : Prng) : Data {
        {
            inspirationCost = prng.nextNat(10, 20);
            talesCost = prng.nextNat(15, 25);
            requestCost = prng.nextNat(20, 30);
        };
    };
};
