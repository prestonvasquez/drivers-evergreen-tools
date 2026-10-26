import urllib.request

IMDS_URL = "http://169.254.169.254"


def get_key(key: str, uppercase: bool) -> str:
    if uppercase:
        return key.upper()
    return key


def imds_get(path: str, timeout=None) -> str:
    """Read EC2 instance metadata with an IMDSv2 session token.

    Hosts that require IMDSv2 (e.g. Ubuntu 24.04) reject token-less requests
    with 401, and hosts that allow IMDSv1 accept tokens too.
    """
    token_req = urllib.request.Request(
        IMDS_URL + "/latest/api/token",
        method="PUT",
        headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
    )
    token = urllib.request.urlopen(token_req, timeout=timeout).read().decode()

    req = urllib.request.Request(
        IMDS_URL + path, headers={"X-aws-ec2-metadata-token": token}
    )
    return urllib.request.urlopen(req, timeout=timeout).read().decode()
