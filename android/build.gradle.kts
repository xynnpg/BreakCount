allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix for old Flutter plugins: missing namespace (AGP 8+) and JVM target mismatch.
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null) {
                // Inject namespace from AndroidManifest package attribute if missing
                if (android.namespace == null) {
                    val manifest = file("src/main/AndroidManifest.xml")
                    if (manifest.exists()) {
                        val pkg = Regex("""package\s*=\s*"([^"]+)"""")
                            .find(manifest.readText())?.groupValues?.get(1)
                        if (pkg != null) android.namespace = pkg
                    }
                }
                // Align Java and Kotlin JVM targets
                android.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        // Align Kotlin JVM target for any subproject using the Kotlin Android plugin
        extensions.findByType(org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile::class.java)
            ?: tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile::class.java) {
                compilerOptions.jvmTarget.set(
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
                )
            }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
