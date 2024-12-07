#let recipe(yaml_dict) = {
  if type(yaml_dict) != dictionary { 
    panic("expected a dictionary, got type: " + type(yaml_dict))
  }
  page({
    set text(14pt)

    [= #yaml_dict.at("name")]

    text(16pt, [Contributed by: ] + yaml_dict.at("contributor"))

    let s = yaml_dict.at("source", default: none)
    if s != none {
      linebreak()
      text(16pt, [Source: ] + s)
    }

    let t = yaml_dict.at("tools", default: none)
    if t != none {
      [== Tools]
      for tool in t {
        [- #tool]
      }
    }


    [== Ingredients]
    let i = yaml_dict.at("ingredients")
    for ingredient in i {
      if type(ingredient) == dictionary {
        [=== #ingredient.at("group")]
        for item in ingredient.at("items") {
          [- #item]
        }
      } else [- #ingredient]
    }

    let s = yaml_dict.at("steps")
    [== Steps]
    for step in s {
      [+ #step]
    }

    let notes = yaml_dict.at("notes", default: none)
    if notes != none [
      == Notes
      #notes
    ]
  })
}

#let recipes(filenames) = {
  let display_hidden = json.decode(sys.inputs.at("DISPLAY_HIDDEN", default: "false"))

  for filename in filenames {
    let yaml_value = yaml(filename)
    if type(yaml_value) != dictionary { 
      panic("expected a dictionary, got: " + type(yaml_value))
    }
    if display_hidden or not yaml_value.at("hidden", default: false) {
      recipe(yaml_value)
    }
  }
}
