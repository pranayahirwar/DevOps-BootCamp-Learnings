def devStep() {
    echo "This is Dev build process"
}

def  testStep() {
    echo "Here testing take place"
}

def beforProd() {
    echo "Final rechecking before Production Deployment"
    // echo "You have chosen ${params.VERSION} during build"
}


return this
