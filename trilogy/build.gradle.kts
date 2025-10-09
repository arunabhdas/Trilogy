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
