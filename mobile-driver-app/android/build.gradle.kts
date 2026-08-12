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
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// file_picker 8.3.7 hardcodes compileSdk 34 in its own android/build.gradle
// (upstream bug, not something pubspec constraints can fix), which fails
// Gradle's AAR metadata check because its own flutter_plugin_android_lifecycle
// dependency requires compileSdk 36+. Forcing every Android library
// subproject (i.e. every plugin's own AAR module, not our :app module) to
// compile against 36 sidesteps the outdated hardcoded value without patching
// pub-cache or waiting on an upstream release. This must be registered
// before the evaluationDependsOn(":app") block below, which forces early
// evaluation of plugin subprojects - afterEvaluate throws if added once a
// project has already finished evaluating.
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.let { android ->
            android.compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
