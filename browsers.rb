provides 'apps/browsers'

require_plugin "apps"

browsers = Mash.new unless apps[:browsers]

apps[:browsers] = browsers
