import Jama.*; // Java Matrix Library: https://math.nist.gov/javanumerics/jama/

class Floor{
  private Scene scene;
  private int maximumFeetPositions = 500;
  private Matrix historyOfFeetPositions = new Matrix(maximumFeetPositions, 3);
  private PVector averageFeetPosition = new PVector();
  private PVector centerPosition = new PVector();
  private SingularValueDecomposition svd;
  private PVector singularValues = new PVector();
  private PVector basisVectorX;
  private PVector basisVectorY;
  private PVector basisVectorZ;
  private Quaternion orientation;
  private int indexToBeUpdated = 0;
  private boolean bufferIsFull = false;
  private float boxDimension = 2; // "meters"
  private boolean isWaitingForUser = false;
  private boolean isCalibrating = false;
  private boolean isCalibrated = false;
  private boolean enableDraw = false;
  private Plane plane;
  private PVector planeCornerNN; // V-0-
  private PVector planeCornerNP; // V-0+
  private PVector planeCornerPP; // V+0+
  private PVector planeCornerPN; // V+0-
  private PVector boxFacePointXN; // X-
  private PVector boxFacePointXP; // X+
  private PVector boxFacePointYN; // Y-
  private PVector boxFacePointYP; // Y+
  private PVector boxFacePointZN; // Z-
  private PVector boxFacePointZP; // Z+
  
  public Floor(Scene scene){
    this.scene = scene;
  }
  
  public void controlledCalibration(){
    println("Floor Calibration instructions: ");
    println("The calibrator needs at least 10 snapshots of the skeleton in different spots of the room to have a good estimate.");
    println("The reccomended position is upright with legs opened at 45~60 deg.");
    println("The opened legs partially overcomes the issue with reflecting floors.");
    println("Get in position and clap to get a snapshot.");
    this.isCalibrating = true;
    while(this.isCalibrating){
      for(Skeleton skeleton:this.scene.activeSkeletons.values()){
        if(skeleton.features.distanceBetweenHands < 0.1){
          this.addSkeletonFeet(skeleton);
          this.calculateFloor();
        }
      }
      delay(100); // minimum time between snapshots
    }
  }

  public void timedCalibration(){
    println("Floor Calibration instructions: ");
    println("The calibrator needs at least 10 snapshots of the skeleton in different spots of the room to have a good estimate.");
    println("The reccomended position is upright with legs opened at 45~60 deg.");
    println("The opened legs partially overcomes the issue with reflecting floors.");
    println("There will be 5 seconds between each snapshot to walk to a new spot.");
    println("Press ENTER when you are ready");
    this.isWaitingForUser = true;
    int startTime = millis();
    while(true){ // 10 seconds to start the calibration
      if(millis()-startTime < 10000){
        if(this.isCalibrating){
          break;
        }
      } else {
      println("Sorry, timed out! Start calibration again if you want...");
      break;
      }
      delay(100);
    }
    int snapshotCount = 0;
    snapshotLoop:
    while(this.isCalibrating){
      for(int countdown = 2; countdown>0; countdown--){
        println("Snapshot in "+ countdown + " seconds");
        delay(1000);
        if(!this.isCalibrating){
          this.isCalibrated = true;
          break snapshotLoop;
        }
      }
      this.addScene();
      snapshotCount++;
      println("Snapshot count: " + snapshotCount);
    }
  }
  
  public void addScene(){
    for(Skeleton skeleton:this.scene.activeSkeletons.values()){
      this.addSkeletonFeet(skeleton);
    }
    this.calculateFloor();
  }
  
  private void addSkeletonFeet(Skeleton skeleton){
    if(!bufferIsFull){
      float maxAccelerationAccepted = 0.5; // test this parameter
      float maxVelocityAccepted = 0.5; // test this parameter
      if(skeleton.joints[FOOT_LEFT].trackingState == 2 && skeleton.joints[FOOT_LEFT].estimatedAcceleration.mag() < maxAccelerationAccepted && skeleton.joints[FOOT_LEFT].estimatedVelocity.mag() < maxVelocityAccepted){ // if FootLeft is tracked and steady
        this.addFoot(skeleton.joints[FOOT_LEFT]);  
      }
      if(skeleton.joints[FOOT_RIGHT].trackingState == 2 && skeleton.joints[FOOT_RIGHT].estimatedAcceleration.mag() < maxAccelerationAccepted && skeleton.joints[FOOT_RIGHT].estimatedVelocity.mag() < maxVelocityAccepted){ // if FootRight is tracked and steady
        this.addFoot(skeleton.joints[FOOT_RIGHT]);  
      }
    }
  }
  
  private void addFoot(Joint footJoint){ 
    if(this.indexToBeUpdated < 3){
      this.historyOfFeetPositions.set(this.indexToBeUpdated, 0, footJoint.estimatedPosition.x);
      this.historyOfFeetPositions.set(this.indexToBeUpdated, 1, footJoint.estimatedPosition.y);
      this.historyOfFeetPositions.set(this.indexToBeUpdated, 2, footJoint.estimatedPosition.z);
      this.indexToBeUpdated++;
    } 
    else {
      if(this.indexToBeUpdated < maximumFeetPositions){ 
        this.historyOfFeetPositions.set(this.indexToBeUpdated, 0, footJoint.estimatedPosition.x);
        this.historyOfFeetPositions.set(this.indexToBeUpdated, 1, footJoint.estimatedPosition.y);
        this.historyOfFeetPositions.set(this.indexToBeUpdated, 2, footJoint.estimatedPosition.z);
        this.updateAverageFeetPosition();
        this.indexToBeUpdated++;
      }
      else {
        this.bufferIsFull = true;
        println("buffer is full");
      }
    }
  }
  
  private void updateAverageFeetPosition(){
    double[] sumOfFeetPositions = new double[3];
    double[] averageFeetPosition = new double[3];
    float[] feetPositionVariance = new float[3];
    float[] feetPositionStandardDeviation = new float[3];
    for(int col=0; col<3; col++){
      for (int row=0; row<this.indexToBeUpdated; row++){
        sumOfFeetPositions[col] = sumOfFeetPositions[col]+this.historyOfFeetPositions.get(row, col);
      }
      averageFeetPosition[col] = sumOfFeetPositions[col]/this.indexToBeUpdated; 
      for (int row=0; row<this.indexToBeUpdated; row++){
        feetPositionVariance[col] = feetPositionVariance[col]+sq((float)(this.historyOfFeetPositions.get(row, col)-averageFeetPosition[col]));
      }
      feetPositionStandardDeviation[col] = sqrt(feetPositionVariance[col]/(this.indexToBeUpdated-1)); 
    }
    this.averageFeetPosition = new PVector((float)averageFeetPosition[0], (float)averageFeetPosition[1], (float)averageFeetPosition[2]);
  }

  private void calculateFloor(){
    if(this.indexToBeUpdated > 3){
      Matrix filledHistoryOfFeetPositions = new Matrix(this.indexToBeUpdated, 3);
      for(int row=0; row<this.indexToBeUpdated-1; row++){
        filledHistoryOfFeetPositions.set(row, 0, this.historyOfFeetPositions.get(row, 0)-this.averageFeetPosition.x);
        filledHistoryOfFeetPositions.set(row, 1, this.historyOfFeetPositions.get(row, 1)-this.averageFeetPosition.y);
        filledHistoryOfFeetPositions.set(row, 2, this.historyOfFeetPositions.get(row, 2)-this.averageFeetPosition.z);
      }
      this.svd = filledHistoryOfFeetPositions.svd();
      double[] singularValues = this.svd.getSingularValues();
      double[][] basisVectors = this.svd.getV().getArray();
      Matrix floorCoordinateSystemRotationMatrix = arrangeBasisVectorDirections(basisVectors, singularValues);
      findBoxFacePoints(filledHistoryOfFeetPositions);
      findCenterPosition();
      this.orientation = rotationMatrixToQuaternion2(floorCoordinateSystemRotationMatrix);
      this.plane = new Plane(this.basisVectorX, this.basisVectorZ, this.centerPosition);
      this.enableDraw = true;
    }
  }
  
  private void findCenterPosition(){
    this.planeCornerNN = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXN, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.averageFeetPosition, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZN, this.basisVectorZ))); // V-0-
    this.planeCornerNP = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXN, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.averageFeetPosition, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZP, this.basisVectorZ))); // V-0+
    this.planeCornerPP = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXP, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.averageFeetPosition, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZP, this.basisVectorZ))); // V+0+
    this.planeCornerPN = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXP, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.averageFeetPosition, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZN, this.basisVectorZ))); // V+0-
    this.centerPosition = PVector.add(this.planeCornerNN, this.planeCornerNP).add(this.planeCornerPP).add(this.planeCornerPN).div(4);
  }
  
  private void findBoxFacePoints(Matrix filledHistoryOfFeetPositions){
    PVector positiveFarIndex = new PVector(-10,-10,-10); //gambiarra
    PVector negativeFarIndex = new PVector(10,10,10); //gambiarra
    for(int row=0; row<filledHistoryOfFeetPositions.getRowDimension(); row++){
      PVector point = new PVector((float)filledHistoryOfFeetPositions.get(row, 0), (float)filledHistoryOfFeetPositions.get(row, 1), (float)filledHistoryOfFeetPositions.get(row, 2));
      float basisXProjection = PVector.dot(point, this.basisVectorX);
      float basisYProjection = PVector.dot(point, this.basisVectorY);
      float basisZProjection = PVector.dot(point, this.basisVectorZ);
      if(basisXProjection > positiveFarIndex.x) {
        positiveFarIndex.x = basisXProjection; this.boxFacePointXP = PVector.add(point, this.averageFeetPosition);
      }
      if(basisYProjection > positiveFarIndex.y) {
        positiveFarIndex.y = basisYProjection; this.boxFacePointYP = PVector.add(point, this.averageFeetPosition);
      }
      if(basisZProjection > positiveFarIndex.z) {
        positiveFarIndex.z = basisZProjection; this.boxFacePointZP = PVector.add(point, this.averageFeetPosition);
      }
      if(basisXProjection < negativeFarIndex.x) {
        negativeFarIndex.x = basisXProjection; this.boxFacePointXN = PVector.add(point, this.averageFeetPosition);
      }
      if(basisYProjection < negativeFarIndex.y) {
        negativeFarIndex.y = basisYProjection; this.boxFacePointYN = PVector.add(point, this.averageFeetPosition);
      }
      if(basisZProjection < negativeFarIndex.z) {
        negativeFarIndex.z = basisZProjection; this.boxFacePointZN = PVector.add(point, this.averageFeetPosition);
      }
    }
  }
  
  private Matrix arrangeBasisVectorDirections(double[][] basisVectors, double[] singularValues){ // Set the right direction for each basis vector, so that its CSys points in a direction close to the kinect CSys.
    PVector basisVector1 = new PVector((float)basisVectors[0][0], (float)basisVectors[1][0], (float)basisVectors[2][0]);
    PVector basisVector2 = new PVector((float)basisVectors[0][1], (float)basisVectors[1][1], (float)basisVectors[2][1]);
    PVector basisVector3 = new PVector((float)basisVectors[0][2], (float)basisVectors[1][2], (float)basisVectors[2][2]);
    boolean[] usedSingularValues = new boolean[3];
    if(abs(basisVector1.x) >= abs(basisVector2.x) && abs(basisVector1.x) >= abs(basisVector3.x)){
      this.basisVectorX = PVector.mult(basisVector1, Math.signum(basisVector1.x)); 
      this.singularValues.x = (float)singularValues[0];
      usedSingularValues[0] = true;
    } else if(abs(basisVector2.x) >= abs(basisVector3.x)){
      this.basisVectorX = PVector.mult(basisVector2, Math.signum(basisVector2.x));
      this.singularValues.x = (float)singularValues[1];
      usedSingularValues[1] = true;
    } else{
      this.basisVectorX = PVector.mult(basisVector3, Math.signum(basisVector3.x));
      this.singularValues.x = (float)singularValues[2];
      usedSingularValues[2] = true;
    }
    if(abs(basisVector1.y) >= abs(basisVector2.y) && abs(basisVector1.y) >= abs(basisVector3.y)){
      this.basisVectorY = PVector.mult(basisVector1, Math.signum(basisVector1.y));
      this.singularValues.y = (float)singularValues[0];
      usedSingularValues[0] = true;
    } else if(abs(basisVector2.y) >= abs(basisVector3.y)){
      this.basisVectorY = PVector.mult(basisVector2, Math.signum(basisVector2.y));
      this.singularValues.y = (float)singularValues[1];
      usedSingularValues[1] = true;
    } else{
      this.basisVectorY = PVector.mult(basisVector3, Math.signum(basisVector3.y)); 
      this.singularValues.y = (float)singularValues[2];
      usedSingularValues[2] = true;
    }
    this.basisVectorZ = this.basisVectorX.cross(this.basisVectorY);
         if(usedSingularValues[0]==false) this.singularValues.z = (float)singularValues[0];
    else if(usedSingularValues[1]==false) this.singularValues.z = (float)singularValues[1];
    else if(usedSingularValues[2]==false) this.singularValues.z = (float)singularValues[2];
    this.singularValues.normalize();
    Matrix coordinateSystem = new Matrix(3, 3);
    coordinateSystem.set(0, 0, (double)this.basisVectorX.x);
    coordinateSystem.set(1, 0, (double)this.basisVectorX.y);
    coordinateSystem.set(2, 0, (double)this.basisVectorX.z);
    coordinateSystem.set(0, 1, (double)this.basisVectorY.x);
    coordinateSystem.set(1, 1, (double)this.basisVectorY.y);
    coordinateSystem.set(2, 1, (double)this.basisVectorY.z);
    coordinateSystem.set(0, 2, (double)this.basisVectorZ.x);
    coordinateSystem.set(1, 2, (double)this.basisVectorZ.y);
    coordinateSystem.set(2, 2, (double)this.basisVectorZ.z);
    return coordinateSystem;
  }
  
  public PVector toFloorCoordinateSystem(PVector globalPosition){
    PVector localPosition;
    if(this.isCalibrated){
      Quaternion auxiliar = new Quaternion(0, PVector.sub(globalPosition, this.centerPosition));
      localPosition = qMult(qConjugate(this.orientation), qMult(auxiliar, this.orientation)).vector;
    } else{
      localPosition = globalPosition;
    }
    return localPosition;
  }
  
  public Quaternion toFloorCoordinateSystem(Quaternion globalOrientation){ // this method was not tested.
    Quaternion localOrientation;
    if(this.isCalibrated){
      localOrientation = qMult(globalOrientation, qConjugate(this.orientation));
    } else {
      localOrientation = globalOrientation;
    }
    return localOrientation;
  }
  
  public void draw(boolean coordinateSystem, boolean box, boolean plane){
    if(this.isCalibrated){
      if(plane){
        this.drawPlane();
        //this.plane.draw(this.boxDimension);
      }
      if(box){
        //this.drawSVDBox();
        //this.drawExtremePointsBox();
      }
      if(coordinateSystem){
        this.drawCoordinateSystem(true, false); // fromQuaternion, fromSVDBasis
      }
    }
    else if(this.isCalibrating){
      this.drawData();
      if(this.enableDraw){
        if(plane){
          this.drawPlane();
          //this.plane.draw(this.boxDimension);
        }
        if(box){
          //this.drawSVDBox();
          this.drawExtremePointsBox();
        }
        if(coordinateSystem){
          this.drawCoordinateSystem(true, false); // fromQuaternion, fromSVDBasis
        }
      }
    }
  }
  
  public void drawPlane(){
    if(this.indexToBeUpdated > 3){
      stroke(this.scene.roomColor);
      fill(color(30, 60, 90, 128));
      beginShape();
      vertex(reScaleX(this.planeCornerNN.x), reScaleY(this.planeCornerNN.y), reScaleZ(this.planeCornerNN.z));
      vertex(reScaleX(this.planeCornerNP.x), reScaleY(this.planeCornerNP.y), reScaleZ(this.planeCornerNP.z));
      vertex(reScaleX(this.planeCornerPP.x), reScaleY(this.planeCornerPP.y), reScaleZ(this.planeCornerPP.z));
      vertex(reScaleX(this.planeCornerPN.x), reScaleY(this.planeCornerPN.y), reScaleZ(this.planeCornerPN.z));
      endShape(CLOSE);
    }
  }
  
  public void drawExtremePointsBox(){
    if(this.indexToBeUpdated > 3){
      stroke(this.scene.roomColor);
      
      // Lower face:
      PVector floorCorner1 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXN, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYN, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZN, this.basisVectorZ))); // V---
      PVector floorCorner2 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXN, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYN, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZP, this.basisVectorZ))); // V--+
      PVector floorCorner3 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXP, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYN, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZP, this.basisVectorZ))); // V+-+
      PVector floorCorner4 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXP, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYN, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZN, this.basisVectorZ))); // V+--
      
      // Upper face:
      PVector floorCorner5 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXN, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYP, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZN, this.basisVectorZ))); // V-+-
      PVector floorCorner6 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXN, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYP, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZP, this.basisVectorZ))); // V-++
      PVector floorCorner7 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXP, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYP, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZP, this.basisVectorZ))); // V+++
      PVector floorCorner8 = PVector.mult(this.basisVectorX, PVector.dot(this.boxFacePointXP, this.basisVectorX)).add(PVector.mult(this.basisVectorY, PVector.dot(this.boxFacePointYP, this.basisVectorY))).add(PVector.mult(this.basisVectorZ, PVector.dot(this.boxFacePointZN, this.basisVectorZ))); // V++-
      
      noFill();
      stroke(this.scene.roomColor);
      // Lower Face:
      beginShape();
      vertex(reScaleX(floorCorner1.x), reScaleY(floorCorner1.y), reScaleZ(floorCorner1.z));
      vertex(reScaleX(floorCorner2.x), reScaleY(floorCorner2.y), reScaleZ(floorCorner2.z));
      vertex(reScaleX(floorCorner3.x), reScaleY(floorCorner3.y), reScaleZ(floorCorner3.z));
      vertex(reScaleX(floorCorner4.x), reScaleY(floorCorner4.y), reScaleZ(floorCorner4.z));
      endShape(CLOSE);
      
      // Upper Face:
      beginShape();
      vertex(reScaleX(floorCorner5.x), reScaleY(floorCorner5.y), reScaleZ(floorCorner5.z));
      vertex(reScaleX(floorCorner6.x), reScaleY(floorCorner6.y), reScaleZ(floorCorner6.z));
      vertex(reScaleX(floorCorner7.x), reScaleY(floorCorner7.y), reScaleZ(floorCorner7.z));
      vertex(reScaleX(floorCorner8.x), reScaleY(floorCorner8.y), reScaleZ(floorCorner8.z));
      endShape(CLOSE);
      
      // Connecting Lines:
      beginShape(LINES);
      vertex(reScaleX(floorCorner1.x), reScaleY(floorCorner1.y), reScaleZ(floorCorner1.z));
      vertex(reScaleX(floorCorner5.x), reScaleY(floorCorner5.y), reScaleZ(floorCorner5.z));
      vertex(reScaleX(floorCorner2.x), reScaleY(floorCorner2.y), reScaleZ(floorCorner2.z));
      vertex(reScaleX(floorCorner6.x), reScaleY(floorCorner6.y), reScaleZ(floorCorner6.z));
      vertex(reScaleX(floorCorner3.x), reScaleY(floorCorner3.y), reScaleZ(floorCorner3.z));
      vertex(reScaleX(floorCorner7.x), reScaleY(floorCorner7.y), reScaleZ(floorCorner7.z));
      vertex(reScaleX(floorCorner4.x), reScaleY(floorCorner4.y), reScaleZ(floorCorner4.z));
      vertex(reScaleX(floorCorner8.x), reScaleY(floorCorner8.y), reScaleZ(floorCorner8.z));
      endShape();
    }
  }
  
  public void drawSVDBox(){
    if(this.indexToBeUpdated > 3){
      float floorWidth = this.boxDimension*this.singularValues.x;
      float floorThickness = this.boxDimension*this.singularValues.y;
      float floorLength = this.boxDimension*this.singularValues.z;
      
      // Lower face:
      PVector floorCorner1 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, floorLength)).add(PVector.mult(this.basisVectorZ, floorWidth)).add(PVector.mult(this.basisVectorY, floorThickness));
      PVector floorCorner2 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, -floorLength)).add(PVector.mult(this.basisVectorZ, floorWidth)).add(PVector.mult(this.basisVectorY, floorThickness));
      PVector floorCorner3 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, -floorLength)).add(PVector.mult(this.basisVectorZ, -floorWidth)).add(PVector.mult(this.basisVectorY, floorThickness));
      PVector floorCorner4 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, floorLength)).add(PVector.mult(this.basisVectorZ, -floorWidth)).add(PVector.mult(this.basisVectorY, floorThickness));
  
      // Upper Face:
      PVector floorCorner5 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, floorLength)).add(PVector.mult(this.basisVectorZ, floorWidth)).add(PVector.mult(this.basisVectorY, -floorThickness));
      PVector floorCorner6 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, -floorLength)).add(PVector.mult(this.basisVectorZ, floorWidth)).add(PVector.mult(this.basisVectorY, -floorThickness));
      PVector floorCorner7 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, -floorLength)).add(PVector.mult(this.basisVectorZ, -floorWidth)).add(PVector.mult(this.basisVectorY, -floorThickness));
      PVector floorCorner8 = PVector.add(this.averageFeetPosition, PVector.mult(this.basisVectorX, floorLength)).add(PVector.mult(this.basisVectorZ, -floorWidth)).add(PVector.mult(this.basisVectorY, -floorThickness));
      
      noFill();
      stroke(this.scene.roomColor);
      // Lower Face:
      beginShape();
      vertex(reScaleX(floorCorner1.x), reScaleY(floorCorner1.y), reScaleZ(floorCorner1.z));
      vertex(reScaleX(floorCorner2.x), reScaleY(floorCorner2.y), reScaleZ(floorCorner2.z));
      vertex(reScaleX(floorCorner3.x), reScaleY(floorCorner3.y), reScaleZ(floorCorner3.z));
      vertex(reScaleX(floorCorner4.x), reScaleY(floorCorner4.y), reScaleZ(floorCorner4.z));
      endShape(CLOSE);
      
      // Upper Face:
      beginShape();
      vertex(reScaleX(floorCorner5.x), reScaleY(floorCorner5.y), reScaleZ(floorCorner5.z));
      vertex(reScaleX(floorCorner6.x), reScaleY(floorCorner6.y), reScaleZ(floorCorner6.z));
      vertex(reScaleX(floorCorner7.x), reScaleY(floorCorner7.y), reScaleZ(floorCorner7.z));
      vertex(reScaleX(floorCorner8.x), reScaleY(floorCorner8.y), reScaleZ(floorCorner8.z));
      endShape(CLOSE);
      
      // Connecting Lines:
      beginShape(LINES);
      vertex(reScaleX(floorCorner1.x), reScaleY(floorCorner1.y), reScaleZ(floorCorner1.z));
      vertex(reScaleX(floorCorner5.x), reScaleY(floorCorner5.y), reScaleZ(floorCorner5.z));
      vertex(reScaleX(floorCorner2.x), reScaleY(floorCorner2.y), reScaleZ(floorCorner2.z));
      vertex(reScaleX(floorCorner6.x), reScaleY(floorCorner6.y), reScaleZ(floorCorner6.z));
      vertex(reScaleX(floorCorner3.x), reScaleY(floorCorner3.y), reScaleZ(floorCorner3.z));
      vertex(reScaleX(floorCorner7.x), reScaleY(floorCorner7.y), reScaleZ(floorCorner7.z));
      vertex(reScaleX(floorCorner4.x), reScaleY(floorCorner4.y), reScaleZ(floorCorner4.z));
      vertex(reScaleX(floorCorner8.x), reScaleY(floorCorner8.y), reScaleZ(floorCorner8.z));
      endShape();
    }
  }
  
  private void drawCoordinateSystem(boolean fromQuaternion, boolean fromSVDBasis){
    if(fromQuaternion){
      PVector coordinateSystemDirectionX = qMult(qMult(this.orientation, new Quaternion(0, 1, 0, 0)), qConjugate(this.orientation)).vector; 
      PVector coordinateSystemDirectionY = qMult(qMult(this.orientation, new Quaternion(0, 0, 1, 0)), qConjugate(this.orientation)).vector; 
      PVector coordinateSystemDirectionZ = qMult(qMult(this.orientation, new Quaternion(0, 0, 0, 1)), qConjugate(this.orientation)).vector; 
      //println("coordinateSystemDirectionX mag: "+coordinateSystemDirectionX.mag());
      pushMatrix();
      translate(reScaleX(this.centerPosition.x), reScaleY(this.centerPosition.y), reScaleZ(this.centerPosition.z));
      strokeWeight(5);
      float size = 0.5; // meters
      stroke(255, 0, 0, 170);
      line(0, 0, 0, reScaleX(size*coordinateSystemDirectionX.x), reScaleY(size*coordinateSystemDirectionX.y), reScaleZ(size*coordinateSystemDirectionX.z)); // The Processing's coordinate system is inconsistent (X cross Y != Z)
      stroke(0, 255, 0, 170);
      line(0, 0, 0, reScaleX(size*coordinateSystemDirectionY.x), reScaleY(size*coordinateSystemDirectionY.y), reScaleZ(size*coordinateSystemDirectionY.z));
      stroke(0, 0, 255, 170);
      line(0, 0, 0, reScaleX(size*coordinateSystemDirectionZ.x), reScaleY(size*coordinateSystemDirectionZ.y), reScaleZ(size*coordinateSystemDirectionZ.z));
      popMatrix();
    }
    if(fromSVDBasis){
      pushMatrix();
      translate(reScaleX(this.averageFeetPosition.x), reScaleY(this.averageFeetPosition.y), reScaleZ(this.averageFeetPosition.z));
      strokeWeight(5);
      float size = 0.5; // meters
      stroke(255, 0, 0, 170);
      line(0, 0, 0, reScaleX(size*this.basisVectorX.x), reScaleY(size*this.basisVectorX.y), reScaleZ(size*this.basisVectorX.z)); // The Processing's coordinate system is inconsistent (X cross Y != Z)
      stroke(0, 255, 0, 170);
      line(0, 0, 0, reScaleX(size*this.basisVectorY.x), reScaleY(size*this.basisVectorY.y), reScaleZ(size*this.basisVectorY.z));
      stroke(0, 0, 255, 170);
      line(0, 0, 0, reScaleX(size*this.basisVectorZ.x), reScaleY(size*this.basisVectorZ.y), reScaleZ(size*this.basisVectorZ.z));
      popMatrix();
    }
  }
  
  public void drawData(){
    sphereDetail(6);
    for(int j=0; j<this.indexToBeUpdated; j++){
      pushMatrix();
      translate(reScaleX((float)this.historyOfFeetPositions.get(j, 0)), reScaleY((float)this.historyOfFeetPositions.get(j, 1)), reScaleZ((float)this.historyOfFeetPositions.get(j, 2)));
      fill(255, 0, 128, 128);
      noStroke();
      sphere(5);
      popMatrix();
    }
    pushMatrix();
    translate(reScaleX(averageFeetPosition.x), reScaleY(averageFeetPosition.y), reScaleZ(averageFeetPosition.z));
    fill(255, 128, 64, 128);
    noStroke();
    sphere(5);
    popMatrix();    
  }
}

void startTimedCalibration(){ // This method exists to make possible to calibrate on another thread other than the draw() loop.
  scene.floor.timedCalibration(); 
}

void startControlledCalibration(){ // This method exists to make possible to calibrate on another thread other than the draw() loop.
  scene.floor.controlledCalibration();
}
