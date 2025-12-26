// Jenkins Pipeline Job Configuration for Large File Detection and Cleanup
// Save as: Jenkinsfile or create a new Pipeline job with this content

pipeline {
    agent any
    
    options {
        // Keep last 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Timeout after 1 hour
        timeout(time: 1, unit: 'HOURS')
    }
    
    triggers {
        // Run every day at 2 AM
        cron('0 2 * * *')
        
        // Also allow manual trigger
        pollSCM('')
    }
    
    environment {
        LARGE_FILE_THRESHOLD = '50M'
        CLEAN_FILE_THRESHOLD = '50M'
        LOG_FILE = 'jenkins_cleanup.log'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo 'Checking out repository...'
                    checkout scm
                }
            }
        }
        
        stage('Detect Large Files') {
            steps {
                script {
                    echo "Detecting files larger than ${LARGE_FILE_THRESHOLD}..."
                    
                    sh '''
                        find . -type f -size +${LARGE_FILE_THRESHOLD} ! -path "./.git/*" > large_files.txt 2>/dev/null || true
                        
                        if [ -s large_files.txt ]; then
                            echo "Found large files:"
                            cat large_files.txt
                            exit 1
                        else
                            echo "No large files detected."
                            exit 0
                        fi
                    '''
                }
            }
        }
        
        stage('Cleanup Large Files') {
            when {
                expression {
                    return fileExists('large_files.txt') && readFile('large_files.txt').trim() != ''
                }
            }
            steps {
                script {
                    echo 'Cleaning up large files...'
                    
                    sh '''
                        mkdir -p large_files_backup
                        
                        while IFS= read -r file; do
                            if [ -f "$file" ]; then
                                echo "Moving: $file"
                                mv "$file" large_files_backup/ || echo "Failed to move $file"
                            fi
                        done < large_files.txt
                        
                        echo "Large files backed up to: large_files_backup/"
                    '''
                }
            }
        }
        
        stage('Commit Small Files') {
            steps {
                script {
                    echo 'Committing files smaller than threshold...'
                    
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', 
                                                     usernameVariable: 'GIT_USER', 
                                                     passwordVariable: 'GIT_PASS')]) {
                        sh '''
                            git config user.email "jenkins@example.com"
                            git config user.name "Jenkins Automation"
                            
                            # Stage small files
                            find . -type f -size -${CLEAN_FILE_THRESHOLD} ! -path "./.git/*" ! -path "./large_files_backup/*" -print0 | \
                                xargs -0 git add 2>/dev/null || true
                            
                            # Commit if there are changes
                            if git diff --cached --quiet; then
                                echo "No changes to commit."
                            else
                                git commit -m "[Jenkins] Auto-commit small files at $(date '+%Y-%m-%d %H:%M:%S')" || true
                                git push origin HEAD:${GIT_BRANCH} || echo "Failed to push changes"
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('Cleanup Artifacts') {
            steps {
                script {
                    echo 'Cleaning up temporary files...'
                    
                    sh '''
                        rm -f large_files.txt
                        echo "Cleanup completed."
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo 'Pipeline execution completed.'
                
                // Archive logs
                sh '''
                    if [ -f "${LOG_FILE}" ]; then
                        cp "${LOG_FILE}" "${WORKSPACE}/"
                    fi
                '''
                
                // Archive artifacts
                archiveArtifacts artifacts: 'jenkins_cleanup.log', 
                                 allowEmptyArchive: true
            }
        }
        
        failure {
            script {
                echo 'Pipeline failed! Sending notifications...'
                // Add email notification if configured
                // emailext(subject: "Jenkins Job Failed: ${env.JOB_NAME}",
                //          body: "Build #${env.BUILD_NUMBER} failed. Check console output at ${env.BUILD_URL}",
                //          to: "${env.CHANGE_AUTHOR_EMAIL}")
            }
        }
        
        success {
            script {
                echo 'Pipeline succeeded!'
            }
        }
    }
}

// Alternative Declarative Job Configuration (XML format)
/*
<?xml version='1.1' encoding='UTF-8'?>
<project>
    <properties>
        <hudson.model.ParametersDefinitionProperty>
            <parameterDefinitions>
                <hudson.model.StringParameterDefinition>
                    <name>LARGE_FILE_THRESHOLD</name>
                    <defaultValue>50M</defaultValue>
                </hudson.model.StringParameterDefinition>
            </parameterDefinitions>
        </hudson.model.ParametersDefinitionProperty>
    </properties>
    <triggers>
        <com.synopsys.arc.jenkinsci.plugins.timertrigger.TimerTrigger>
            <spec>0 2 * * *</spec>
        </com.synopsys.arc.jenkinsci.plugins.timertrigger.TimerTrigger>
    </triggers>
    <builders>
        <hudson.tasks.Shell>
            <command>
#!/bin/bash
echo "Detecting large files..."
find . -type f -size +${LARGE_FILE_THRESHOLD} ! -path "./.git/*" | tee large_files.txt
            </command>
        </hudson.tasks.Shell>
    </builders>
</project>
*/
