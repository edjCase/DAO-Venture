import Http "mo:certified-cache/Http";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import CertifiedCache "mo:certified-cache";
import GameHandler "GameHandler";
import Image "../models/Image";
import Nat32 "mo:base/Nat32";
import IterTools "mo:itertools/Iter";

module {
    public type HttpRequest = Http.HttpRequest;
    public type HttpResponse = Http.HttpResponse;
    public type HttpUpdateRequest = {
        method : Text;
        url : Text;
        headers : [Http.HeaderField];
        body : Blob;
    };

    public class Handler(gameHandler : GameHandler.Handler) {

        var entries : [(Text, (Blob, Nat))] = [];

        let two_days_in_nanos = 2 * 24 * 60 * 60 * 1000 * 1000 * 1000; // TODO length?

        var imageResponseCache = CertifiedCache.fromEntries<Text, Blob>(
            entries,
            Text.equal,
            Text.hash,
            Text.encodeUtf8,
            func(b : Blob) : Blob { b },
            two_days_in_nanos + Int.abs(Time.now()),
        );

        // TODO cant figure out why cert is invalid
        // var etagResponseCache = CertifiedCache.fromEntries<Text, Blob>(
        //     entries,
        //     Text.equal,
        //     Text.hash,
        //     Text.encodeUtf8,
        //     func(b : Blob) : Blob { b },
        //     two_days_in_nanos + Int.abs(Time.now()),
        // );

        let eTagBlob = Blob.fromArray([]);

        public func http_request(req : HttpRequest) : HttpResponse {
            let ?imageId = getImageId(req.url) else return build404Response(null);
            let ?image = gameHandler.getImage(imageId) else return build404Response(null);

            let etag = buildEtag(image.data);

            Debug.print("ETag: " # etag);

            // TODO cant figure out why cert is invalid
            // switch (etagResponseCache.get(req.url)) {
            //     case (?_) {
            //         Debug.print("ETag cache hit");
            //         if (hasEtagCacheHeader(req, etag)) {
            //             Debug.print("ETag cache hit and request has ETag header");
            //             return {
            //                 status_code = 304;
            //                 headers = [
            //                     ("ETag", etag),
            //                     ("Cache-Control", "public, max-age=3600"),
            //                     etagResponseCache.certificationHeader(req.url),
            //                 ];
            //                 body = eTagBlob;
            //                 streaming_strategy = null;
            //                 upgrade = null;
            //             };
            //         };
            //     };
            //     case (null) {};
            // };

            switch (imageResponseCache.get(req.url)) {
                case (?body) {
                    let contentType = getContentType(image.kind);
                    return {
                        status_code = 200;
                        headers = [
                            ("content-type", contentType),
                            ("ETag", etag),
                            ("Cache-Control", "public, max-age=3600"),
                            imageResponseCache.certificationHeader(req.url),
                        ];
                        body = body;
                        streaming_strategy = null;
                        upgrade = null;
                    };
                };
                case (null) {
                    return build404Response(?true);
                };
            };
        };

        public func http_request_update(req : HttpUpdateRequest) : HttpResponse {
            Debug.print("Received update request: " # req.url);
            let ?imageId = getImageId(req.url) else return build404Response(null);

            let ?image = gameHandler.getImage(imageId) else return build404Response(null);

            let contentType = getContentType(image.kind);
            let etag = buildEtag(image.data);

            imageResponseCache.put(req.url, image.data, null);

            // TODO cant figure out why cert is invalid
            // etagResponseCache.put(req.url, eTagBlob, ?two_days_in_nanos);

            if (hasEtagCacheHeader(req, etag)) {
                Debug.print("ETag cache hit and request has ETag header");
                return {
                    status_code = 304;
                    headers = [
                        ("ETag", etag),
                        ("Cache-Control", "public, max-age=3600"),
                    ];
                    body = eTagBlob;
                    streaming_strategy = null;
                    upgrade = null;
                };
            };

            {
                status_code = 200;
                headers = [
                    ("content-type", contentType),
                    ("ETag", etag),
                    ("Cache-Control", "public, max-age=3600"),
                ];
                body = image.data;
                streaming_strategy = null;
                upgrade = null;
            };
        };

        private func hasEtagCacheHeader(req : HttpRequest, eTag : Text) : Bool {
            req.headers.vals()
            |> IterTools.any(
                _,
                func(header : Http.HeaderField) : Bool = header.0 == "if-none-match" and header.1 == eTag,
            );
        };

        private func buildEtag(blob : Blob) : Text {
            "\"" # Nat32.toText(Blob.hash(blob)) # "\"";
        };

        private func getImageId(url : Text) : ?Text {
            let ?end = Text.stripStart(url, #text("/images/")) else return null;
            Text.split(end, #char('?')).next();
        };

        private func build404Response(upgrade : ?Bool) : HttpResponse {
            {
                status_code = 404;
                headers = [];
                body = Blob.fromArray([]);
                streaming_strategy = null;
                upgrade = upgrade;
            };
        };

        private func getContentType(kind : Image.ImageKind) : Text {
            switch kind {
                case (#png) "image/png";
            };
        };
    };
};
