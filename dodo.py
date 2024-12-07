import json
import subprocess
from pathlib import Path
from typing import Literal

PWD = Path(__file__).parent

TEMPLATE = PWD / "template.typ"
RECIPES = tuple((PWD / "recipes").rglob("*.yaml"))


def task_build_template():
    def build_template():
        recipes = tuple(
            "/" + "/".join(recipe.relative_to(PWD).parts) for recipe in RECIPES
        )
        lines = [
            '#import "pages/title.typ": title-page',
            '#import "pages/recipe.typ": recipes',
            "",
            '#title-page("/config.yaml")',
            # evil work-avoidance
            "#recipes((" + json.dumps(recipes)[1:-1] + "))",
        ]

        _ = TEMPLATE.write_text("\n".join(lines))

    return {"actions": [build_template], "file_dep": RECIPES, "targets": [TEMPLATE]}


def task_build_pdfs():
    def build_pdf(target: str, display_hidden: Literal["true", "false"]):
        _ = subprocess.run(
            (
                "typst",
                "compile",
                "template.typ",
                target,
                "--input",
                f"DISPLAY_HIDDEN={display_hidden}",
            )
        )

    (PWD / "dist").mkdir(exist_ok=True)

    for name, display in [
        ("normal", "false"),
        ("full", "true"),
    ]:
        target = f"dist/{name}.pdf"
        yield {
            "actions": [(build_pdf, [target, display])],
            "file_dep": [TEMPLATE, *RECIPES],
            "targets": [target],
            "name": target,
        }
