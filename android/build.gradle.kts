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
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    val projectRoot = project.projectDir.toPath().root
    val buildRoot = newSubprojectBuildDir.asFile.toPath().root

    project.layout.buildDirectory.value(
        if (projectRoot == buildRoot) {
            newSubprojectBuildDir
        } else {
            project.layout.projectDirectory.dir("build")
        }
    )
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
