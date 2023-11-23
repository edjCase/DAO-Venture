import Time "mo:base/Time";
import Array "mo:base/Array";
import Offering "Offering";
import MatchAura "MatchAura";
import Team "Team";
import StadiumTypes "../stadium/Types";

module {

    public type SeasonStatus = {
        #notStarted;
        #starting;
        #inProgress : InProgressSeason;
        #completed : CompletedSeason;
    };

    public type InProgressSeason = {
        matchGroups : [InProgressMatchGroup];
    };

    public type InProgressMatchGroup = {
        id : Nat32;
        time : Time.Time;
        state : {
            #notScheduled;
            #scheduleError : ScheduleMatchGroupError;
            #scheduled : {
                matches : [{
                    team1 : {
                        id : Principal;
                        name : Text;
                        logoUrl : Text;
                    };
                    team2 : {
                        id : Principal;
                        name : Text;
                        logoUrl : Text;
                    };
                    offerings : [Offering.Offering];
                    matchAura : MatchAura.MatchAura;
                }];
            };
            #inProgress : {
                stadiumId : Principal;
                matches : [{
                    team1 : {
                        id : Principal;
                        name : Text;
                        logoUrl : Text;
                    };
                    team2 : {
                        id : Principal;
                        name : Text;
                        logoUrl : Text;
                    };
                    state : {
                        #inProgress : {

                        };
                        #completed : {
                            team1Score : Nat;
                            team2Score : Nat;
                            winner : Team.TeamId;
                        };
                    };
                }];
            };
            #completed : {
                matches : [{
                    team1 : {
                        id : Principal;
                        name : Text;
                        logoUrl : Text;
                        score : Nat;
                    };
                    team2 : {
                        id : Principal;
                        name : Text;
                        logoUrl : Text;
                        score : Nat;
                    };
                    winner : Team.TeamId;
                }];
            };
        };
    };

    // Completed Season
    public type CompletedSeason = {
        teams : [{
            id : Principal;
            name : Text;
            logoUrl : Text;
            standing : Nat;
            wins : Nat;
            losses : Nat;
        }];
        matchGroups : [{
            id : Nat32;
            time : Time.Time;
            state : {
                #ok : {
                    matches : [{
                        team1 : {
                            id : Principal;
                            name : Text;
                            logoUrl : Text;
                            score : Nat;
                        };
                        team2 : {
                            id : Principal;
                            name : Text;
                            logoUrl : Text;
                            score : Nat;
                        };
                        winner : Team.TeamId;
                    }];
                };
                #canceled : {
                    matches : [{
                        team1 : {
                            id : Principal;
                            name : Text;
                            logoUrl : Text;
                        };
                        team2 : {
                            id : Principal;
                            name : Text;
                            logoUrl : Text;
                        };
                    }];
                    reason : {
                        #endedEarly;
                        #scheduleError : ScheduleMatchGroupError;
                    };
                };
            };
        }];
    };

    public type ScheduleMatchGroupError = StadiumTypes.ScheduleMatchGroupError or {
        #stadiumScheduleCallError : Text;
    };
};
