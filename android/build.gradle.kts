allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 1. Configuración de directorios
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // 2. Dependencia de evaluación
    project.evaluationDependsOn(":app")

    // 3. Parche de Namespace para Isar y otras librerías
    // Quitamos el afterEvaluate para evitar el error de "already evaluated"
    project.plugins.withId("com.android.library") {
        val android = project.extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        if (android.namespace == null) {
            android.namespace = "dev.isar.isar_flutter_libs"
        }
    }
    project.plugins.withId("com.android.application") {
        val android = project.extensions.getByType(com.android.build.gradle.AppExtension::class.java)
        if (android.namespace == null) {
            android.namespace = "com.example.the_finxup_app"
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}