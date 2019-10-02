require_relative "../../../lib/c64"

describe C64::Loaders::Spritemate do

  it "loads a resource" do
    sprites = C64::Loaders::Spritemate.from_file File.join(__dir__, "sprites.spm")
    expect(sprites).to include "red"
    expect(sprites).to include "blue"
  end

end
