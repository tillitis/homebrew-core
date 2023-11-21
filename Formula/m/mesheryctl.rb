class Mesheryctl < Formula
  desc "Command-line utility for Meshery, the cloud native management plane"
  homepage "https://meshery.io"
  url "https://github.com/meshery/meshery.git",
      tag:      "v0.6.180",
      revision: "53b75f0eb0256691d91713340266183614c6a78d"
  license "Apache-2.0"
  head "https://github.com/meshery/meshery.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "703a5f1df8ac8341289f5eb5c392ede8beb29d79daded350b6be8eb2e14df646"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "703a5f1df8ac8341289f5eb5c392ede8beb29d79daded350b6be8eb2e14df646"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "703a5f1df8ac8341289f5eb5c392ede8beb29d79daded350b6be8eb2e14df646"
    sha256 cellar: :any_skip_relocation, sonoma:         "54b14adb2439872d78c58a3501a265aece08f5b6639e9c2983f530d8360aa294"
    sha256 cellar: :any_skip_relocation, ventura:        "54b14adb2439872d78c58a3501a265aece08f5b6639e9c2983f530d8360aa294"
    sha256 cellar: :any_skip_relocation, monterey:       "54b14adb2439872d78c58a3501a265aece08f5b6639e9c2983f530d8360aa294"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "dcae4c38746753798b2d3f67363557abedf9215c47270ec82f800548d07ada61"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"

    ldflags = %W[
      -s -w
      -X github.com/layer5io/meshery/mesheryctl/internal/cli/root/constants.version=v#{version}
      -X github.com/layer5io/meshery/mesheryctl/internal/cli/root/constants.commitsha=#{Utils.git_short_head}
      -X github.com/layer5io/meshery/mesheryctl/internal/cli/root/constants.releasechannel=stable
    ]

    system "go", "build", *std_go_args(ldflags: ldflags), "./mesheryctl/cmd/mesheryctl"

    generate_completions_from_executable(bin/"mesheryctl", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mesheryctl version 2>&1")
    assert_match "Channel: stable", shell_output("#{bin}/mesheryctl system channel view 2>&1")

    # Test kubernetes error on trying to start meshery
    assert_match "The Kubernetes cluster is not accessible.", shell_output("#{bin}/mesheryctl system start 2>&1", 1)
  end
end
