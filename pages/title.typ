#let title-page(config-path) = {
  let config-dict = yaml(config-path)
  if type(config-dict) != dictionary {
    panic("expected a dictionary, got: " + type(config-dict))
  }
  let font-size = 48pt
  let tc-content = align(center + horizon, config-dict.at("title"))
  let tc-content = text(font-size, tc-content, weight: "bold", font: "Noto Sans")
  page(tc-content)
}
