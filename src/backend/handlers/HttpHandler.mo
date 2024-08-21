import Http "mo:certified-cache/Http";
import Text "mo:base/Text";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import CertifiedCache "mo:certified-cache";
import GameHandler "GameHandler";
import Image "../models/Image";

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

        var cache = CertifiedCache.fromEntries<Text, Blob>(
            entries,
            Text.equal,
            Text.hash,
            Text.encodeUtf8,
            func(b : Blob) : Blob { b },
            two_days_in_nanos + Int.abs(Time.now()),
        );

        public func http_request(req : HttpRequest) : HttpResponse {
            let ?imageId = getImageId(req.url) else return build404Response();
            let ?image = gameHandler.getImage(imageId) else return return build404Response();

            let cachedBody = cache.get(imageId);
            let contentType = getContentType(image.kind);

            switch cachedBody {
                case (?body) {
                    return {
                        status_code : Nat16 = 200;
                        headers = [("content-type", contentType), cache.certificationHeader(req.url)];
                        body = body;
                        streaming_strategy = null;
                        upgrade = null;
                    };
                };
                case null {
                    Debug.print("Request was not found in cache. Upgrading to update request.\n");
                    return {
                        status_code = 404;
                        headers = [];
                        body = Blob.fromArray([]);
                        streaming_strategy = null;
                        upgrade = ?true;
                    };
                };
            };
        };

        public func http_request_update(req : HttpUpdateRequest) : HttpResponse {
            let ?imageId = getImageId(req.url) else return build404Response();

            let ?image = gameHandler.getImage(imageId) else return return build404Response();

            let contentType = getContentType(image.kind);

            {
                status_code : Nat16 = 200;
                headers = [("content-type", contentType)];
                body = image.data;
                streaming_strategy = null;
                upgrade = null;
            };
        };

        private func getImageId(url : Text) : ?Text {
            Text.stripStart(url, #text("/images/"));
        };

        private func build404Response() : HttpResponse {
            {
                status_code = 404;
                headers = [];
                body = Blob.fromArray([]);
                streaming_strategy = null;
                upgrade = null;
            };
        };

        private func getContentType(kind : Image.ImageKind) : Text {
            switch kind {
                case (#png) "image/png";
            };
        };
    };
};
