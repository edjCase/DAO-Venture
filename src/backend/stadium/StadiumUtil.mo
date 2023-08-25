import Principal "mo:base/Principal";
module {

    public func sortTeamIds(teamIds : (Principal, Principal)) : (Principal, Principal) {
        if (teamIds.0 < teamIds.1) {
            return teamIds;
        } else {
            return (teamIds.1, teamIds.0);
        };
    };
};
