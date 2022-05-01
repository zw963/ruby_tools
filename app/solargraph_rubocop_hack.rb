module SolargraphRubocopHack
  def require_rubocop(version = nil)
    require 'rubocop'
  end
end

Solargraph::Diagnostics::RobocopHelpers.prepend SolargraphRubocopHack
