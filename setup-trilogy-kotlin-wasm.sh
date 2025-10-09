#!/bin/bash

# Create project directory
mkdir -p trilogy
cd trilogy

# Create directory structure
mkdir -p src/wasmJsMain/kotlin/trilogy
mkdir -p src/wasmJsMain/resources

# Create settings.gradle.kts
cat > settings.gradle.kts << 'EOF'
rootProject.name = "trilogy"
EOF

# Create gradle.properties
cat > gradle.properties << 'EOF'
kotlin.code.style=official
kotlin.mpp.stability.nowarn=true
EOF

# Create build.gradle.kts with proper opt-in annotation
cat > build.gradle.kts << 'EOF'
plugins {
    kotlin("multiplatform") version "2.0.21"
}

group = "com.trilogy"
version = "1.0.0"

repositories {
    mavenCentral()
}

kotlin {
    @OptIn(org.jetbrains.kotlin.gradle.ExperimentalWasmDsl::class)
    wasmJs {
        moduleName = "trilogy"
        browser {
            commonWebpackConfig {
                outputFileName = "trilogy.js"
            }
        }
        binaries.executable()
    }

    sourceSets {
        val wasmJsMain by getting {
            dependencies {
                implementation("org.jetbrains.kotlinx:kotlinx-browser:0.2")
            }
        }
    }
}
EOF

# Create Main.kt with all necessary imports
cat > src/wasmJsMain/kotlin/trilogy/Main.kt << 'EOF'
package trilogy

import kotlinx.browser.document
import kotlinx.browser.window
import org.w3c.dom.*
import org.w3c.dom.events.Event
import org.w3c.dom.events.KeyboardEvent

data class Project(
    val id: Int,
    val name: String,
    val description: String,
    var completed: Boolean = false
)

class TrilogyApp {
    private val projects = mutableListOf<Project>()
    private var nextId = 1

    fun initialize() {
        renderApp()
        setupEventListeners()
    }

    private fun renderApp() {
        val root = document.getElementById("root") ?: return

        root.innerHTML = """
            <div class="container">
                <div class="header">
                    <h1>🎯 Trilogy - Project Management</h1>
                    <p>Manage your projects with Kotlin/WASM</p>
                </div>

                <div class="header">
                    <input type="text" id="projectName" placeholder="Project name">
                    <input type="text" id="projectDesc" placeholder="Description">
                    <button id="addProject">Add Project</button>
                </div>

                <div id="projectList"></div>
            </div>
        """.trimIndent()

        renderProjects()
    }

    private fun renderProjects() {
        val projectList = document.getElementById("projectList") ?: return

        if (projects.isEmpty()) {
            projectList.innerHTML = """
                <div class="header">
                    <p>No projects yet. Create your first project above!</p>
                </div>
            """.trimIndent()
            return
        }

        projectList.innerHTML = projects.joinToString("") { project ->
            """
            <div class="project-card" data-id="${project.id}">
                <h3>${if (project.completed) "✅" else "⏳"} ${project.name}</h3>
                <p>${project.description}</p>
                <button class="toggle-btn" data-id="${project.id}">
                    ${if (project.completed) "Mark Incomplete" else "Mark Complete"}
                </button>
                <button class="delete-btn" data-id="${project.id}">Delete</button>
            </div>
            """.trimIndent()
        }

        setupProjectListeners()
    }

    private fun setupEventListeners() {
        val addButton = document.getElementById("addProject") as? HTMLButtonElement
        addButton?.addEventListener("click", {
            addProject()
        })

        val nameInput = document.getElementById("projectName") as? HTMLInputElement
        nameInput?.addEventListener("keypress", { event ->
            if ((event as KeyboardEvent).key == "Enter") {
                addProject()
            }
        })
    }

    private fun setupProjectListeners() {
        document.querySelectorAll(".toggle-btn").asList().forEach { button ->
            button.addEventListener("click", { event ->
                event.stopPropagation()
                val id = (button as HTMLElement).dataset["id"]?.toIntOrNull()
                id?.let { toggleProject(it) }
            })
        }

        document.querySelectorAll(".delete-btn").asList().forEach { button ->
            button.addEventListener("click", { event ->
                event.stopPropagation()
                val id = (button as HTMLElement).dataset["id"]?.toIntOrNull()
                id?.let { deleteProject(it) }
            })
        }
    }

    private fun addProject() {
        val nameInput = document.getElementById("projectName") as? HTMLInputElement
        val descInput = document.getElementById("projectDesc") as? HTMLInputElement

        val name = nameInput?.value?.trim() ?: ""
        val description = descInput?.value?.trim() ?: ""

        if (name.isNotEmpty()) {
            projects.add(Project(nextId++, name, description))
            nameInput?.value = ""
            descInput?.value = ""
            renderProjects()
        }
    }

    private fun toggleProject(id: Int) {
        projects.find { it.id == id }?.let { project ->
            project.completed = !project.completed
            renderProjects()
        }
    }

    private fun deleteProject(id: Int) {
        projects.removeAll { it.id == id }
        renderProjects()
    }
}

fun main() {
    window.onload = {
        println("Trilogy app starting...")
        val app = TrilogyApp()
        app.initialize()
    }
}
EOF

# Create index.html
cat > src/wasmJsMain/resources/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trilogy - Project Management</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            color: #333;
        }

        #root {
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }

        .header {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .project-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            cursor: pointer;
            transition: transform 0.2s;
        }

        .project-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }

        button {
            background: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        button:hover {
            background: #0056b3;
        }

        input {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            width: 300px;
            margin-right: 10px;
        }
    </style>
    <script type="module">
        import { instantiate } from './trilogy.mjs';

        await instantiate();
    </script>
</head>
<body>
    <div id="root"></div>
</body>
</html>
EOF

# Initialize Gradle wrapper
gradle wrapper --gradle-version 8.5

echo "✅ Trilogy project scaffolded successfully!"
echo ""
echo "Next steps:"
echo "  cd trilogy"
echo "  ./gradlew wasmJsBrowserDevelopmentRun"