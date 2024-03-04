export const idlFactory = ({ IDL }) => {
  const AwardPointsRequest = IDL.Record({
    'userId' : IDL.Principal,
    'points' : IDL.Int,
  });
  const AwardPointsResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const TeamAssociationKind = IDL.Variant({
    'fan' : IDL.Null,
    'owner' : IDL.Null,
  });
  const User = IDL.Record({
    'teamAssociation' : IDL.Opt(
      IDL.Record({ 'id' : IDL.Principal, 'kind' : TeamAssociationKind })
    ),
    'points' : IDL.Int,
  });
  const GetUserResult = IDL.Variant({
    'ok' : User,
    'notAuthorized' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const SetUserFavoriteTeamResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadySet' : IDL.Null,
    'identityRequired' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  return IDL.Service({
    'awardPoints' : IDL.Func(
        [IDL.Vec(AwardPointsRequest)],
        [AwardPointsResult],
        [],
      ),
    'get' : IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'setFavoriteTeam' : IDL.Func(
        [IDL.Principal, IDL.Principal],
        [SetUserFavoriteTeamResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
