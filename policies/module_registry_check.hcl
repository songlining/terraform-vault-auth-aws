policy "restrict-module-sources" {
  enforcement_level = "hard-mandatory"
}

# Import the tfplan/v2 module
import "tfplan/v2" as tfplan

# Import the tfconfig/v2 module
import "tfconfig/v2" as tfconfig

# Define allowed module sources
allowed_sources = [
  # Your private registry - modify this to match your organization
  "app.terraform.io/lab-larry",
  
  # Local modules are allowed
  "./",
  "../",
  
  # Add any other allowed sources here
  # "github.com/your-org",
]

# Function to check if a string starts with any of the allowed sources
module_source_allowed = func(source) {
  for allowed_source in allowed_sources {
    if source matches "^" + allowed_source + ".*" {
      return true
    }
  }
  return false
}

# Main rule
main = rule {
  all tfconfig.module_calls as name, module {
    module_source_allowed(module.source)
  }
}