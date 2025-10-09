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
