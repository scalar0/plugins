variable "APE_GH_URL" {
    type    = string
    default = "https://github.com/Attempto/APE.git"
}

variable "CLEX_GH_URL" {
    type    = string
    default = "https://raw.githubusercontent.com/Attempto/Clex/master/clex_lexicon.pl"
}

target "default" {
    dockerfile = "Dockerfile"
    pull       = true
    tags        = ["grace:latest"]
    env = {DEBIAN_FRONTEND = "noninteractive"}
    args = {
        APE_GH_URL = APE_GH_URL
        CLEX_GH_URL = CLEX_GH_URL
    }
}