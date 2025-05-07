import { asyncHandler } from "../Utils/_03_asyncHandler.utils.js";
import { ApiError } from "../Utils/_04_Api_Error.utils.js"
import { User } from "../models/_01_user.model.js"
import { uploadOnCloudinary } from "../Utils/_06_cloudinary.file_uploading.util.js";
import { ApiResponse } from "../Utils/_05_Api_Response.utils.js";
import { get_refresh_access_token } from "../Utils/_07_token_generator.utils.js";

/*
user schema:
 userName: {
            type: String,
            required: true,
            unique: true,
            lowercase: true,
            trim: true, 
            index: true
        },
        email: {
            type: String,
            required: true,
            unique: true,
            lowecase: true,
            trim: true, 
        },
        fullName: {
            type: String,
            required: true,
            trim: true, 
            index: true
        },
        avatar: {
            type: String, // cloudinary url
            required: true,
        },
        coverImage: {
            type: String, // cloudinary url
        },
        watchHistory: [
            {
                type: Schema.Types.ObjectId,
                ref: "Video"
            }
        ],
        password: {
            type: String,
            required: [true, 'Password is required']
        },
        refreshToken: {
            type: String
        }
*/

const registerUser = asyncHandler(
    //steps: getAsJson->validate->checkIfAlreadyExists->ifNotThenTakeAvatar->UploadToCLpudinary->PutInMongoose
    async (req, res) => {

        //step0: upload avatar, done as middleware  
        console.log("Receiving request body.....");
        const { userName, fullName, email, password } = req.body;
        console.log(`recived body for post method register: ${JSON.stringify(req.body)}`);

        //step1: validate if feilds r not empty
        if (
            [userName, fullName, email, password]
                .some(
                    (e) => e?.trim() === ""
                )
        ) {
            throw new ApiError(400, "Username/Fullname/Email/Password cannot be empty !");
        }

        //now fields r valid
        //step2: check if user already exists in DB
        console.log("Checking if user already exists.....");
        const userAlreadyExists = await User.findOne({
            $or: [
                { userName: userName }, // Check if userName exists
                { email: email }        // Check if email exists
            ]
        });
        if (userAlreadyExists) {
            throw new ApiError(400, "Username/Email already exists!");
        }
        //now user is not present in DB

        //multer has now added file in req.body, lets access it to register user
        //step3: upload avatar to clodinary
        console.log("Uploading avatar and coverImage to cloudinary.....");
        const avatarImgLocalPath = req.files?.avatar[0]?.path
        let coverImgLocalPath;
        if (req.files && Array.isArray(req.files.coverImage) && req.files.coverImage.length > 0) {//coz i have not made mandatory to compulsorily pass coverImg
            coverImgLocalPath = req.files.coverImage[0].path
        }
        console.log(`paths received from multer:\n avatar:${avatarImgLocalPath} \n coverImage:${coverImgLocalPath}`);

        //check if files r not null
        if (!avatarImgLocalPath) throw new ApiError(400, "Avatar Image is required!")
        const avatarUploaded = await uploadOnCloudinary(avatarImgLocalPath)
        if (!avatarUploaded) throw new ApiError(400, "Failed to upload avatar Image!")
        const coverImgUploaded = await uploadOnCloudinary(coverImgLocalPath)
        console.log("Images uploaded to clodinary...");

        //now files r uploaded to cloudinary
        //step4: all things r goin good, register user into database
        console.log("Registering user in MongoDB....");
        const userCreatedInDB = await User.create(
            {
                avatar: avatarUploaded.url,
                coverImage: coverImgUploaded?.url || "",
                fullName: fullName,
                userName: userName.toLowerCase(),
                email: email,
                password: password,

            }
        )

        console.log("Cheking if user is registered sucessfully....");
        //check if user created is successfulll, by finding generated id
        const user = await User.findById(
            userCreatedInDB._id
        ).select(
            "-password -refreshToken"  //try selecting all feilds except password and refreshToken
        )

        if (!user) {
            throw new ApiError(400, "Failed to register user!")
        }


        //send success reponse
        console.log(`User registered sucessfully`);
        return res
            .status(200)
            .json(
                new ApiResponse(
                    200,
                    user,
                    `User created succeesfully: User: ${JSON.stringify(user)}`
                )
            )

        /*
          If evrything works fine the response should look like this:
          {
      "statusCode": 200,
      "data": {
          "_id": "681b45b8c04494d446fe1294",
          "userName": "suhail",
          "email": "suhailsharieffsharieff@gmail.com",
          "fullName": "Suhail Sharieff",
          "avatar": "http://res.cloudinary.com/diioxxov8/image/upload/v1746617783/wkmwdakaeeajmpbrg3ga.png",
          "coverImage": "http://res.cloudinary.com/diioxxov8/image/upload/v1746617784/dn1goblnqyw3by2zhrpi.jpg",
          "watchHistory": [],
          "createdAt": "2025-05-07T11:36:24.935Z",
          "updatedAt": "2025-05-07T11:36:24.935Z",
          "__v": 0
      },
      "message": "User created succeesfully: User: {\"_id\":\"681b45b8c04494d446fe1294\",\"userName\":\"suhail\",\"email\":\"suhailsharieffsharieff@gmail.com\",\"fullName\":\"Suhail Sharieff\",\"avatar\":\"http://res.cloudinary.com/diioxxov8/image/upload/v1746617783/wkmwdakaeeajmpbrg3ga.png\",\"coverImage\":\"http://res.cloudinary.com/diioxxov8/image/upload/v1746617784/dn1goblnqyw3by2zhrpi.jpg\",\"watchHistory\":[],\"createdAt\":\"2025-05-07T11:36:24.935Z\",\"updatedAt\":\"2025-05-07T11:36:24.935Z\",\"__v\":0}",
      "success": true
  }
        */
    }




);

    //*******************LOGIN */

    //checkCredentials->ifValidGenerateAnAccessTokenAndRefreshTokenWhichWeWill be using to maintain logged in user session, if user logs out we will refresh the access token, the server will compare the prev and curr since its mismatch it will make user logged out->send access token as cookie(The Cookie is a small message from a web server passed to the user's browser when you visit a website. In other words, Cookies are small text files of information created/updated when visiting a website and stored on the user's web browser. Cookies are commonly used for information about user sections, user preferences and other data on the website. Cookies help websites remember users and track their activities to provide a personalised experience)->once te user is logged in , we can access the user's details just by using these cookies that r continously carried btw server and client

const loginUser=asyncHandler(

    async(req,res)=>{

        
        console.log("Fetching UI data for login...");
        console.log(`Body received for login: ${JSON.stringify(req.body)}`);
        const {userName,email,password}=req.body;

        if(!( password && (userName || email))){
            throw new ApiError(400,"Invalid Credentials!")
        }

        console.log("Checking if user is registered....");

        const user=await User.findOne(
            {
                $or:[
                    {userName:userName},
                    {email:email}
                ],
            }
        )

        if(!user){
            throw new ApiError(400,"Invalid credentials!")
        }

        console.log(`User do exists..matching password...`);
        const passwordCorrect=await user.isPasswordCorrect(password);//we have defined this method in _01_user.models.js
        if(!passwordCorrect){
            throw new ApiError(401,"Invalid Credentials!")
        }
        console.log("User login sucess");

        console.log("Starting generation of refresh token and passing them as cookies so that user data can be accessed via cookies in logged in session...");
        
        const {accessToken,refreshToken}=await get_refresh_access_token(user._id)

        console.log("Sending these tokens as cookies for logged session...");

        return res
        .status(200)
        .cookie(//we have given our website cookie usng app.use(cookie-parser())
            "accessToken",
            accessToken,
            {
                httpOnly:true,
                secure:true
            }
        )
        .cookie(
            "refreshToekn",
            refreshToken,
            {
                httpOnly:true,
                secure:true
            }
        )
        .json(
            new ApiResponse(
                200,
                {
                    user:user,
                    accessToken,//this and below is for like for ex mobile apps whcih doent use cookie
                    refreshToken
                },
                "Login session created!"
            )
        )

        /**Suceess full response would look like this:
         {"statusCode":200,"data":{"user":{"_id":"681b4849995d33c7b494580a","userName":"suhail","email":"suhailsharieffsharieff@gmail.com","fullName":"Suhail Sharieff","avatar":"http://res.cloudinary.com/diioxxov8/image/upload/v1746618440/w6zl3q4qbnulzk4yyjn7.png","coverImage":"http://res.cloudinary.com/diioxxov8/image/upload/v1746618441/trdzp2sfy0oupddvaftn.jpg","watchHistory":[],"password":"$2b$10$CZaKeNYM5HVTjlJxds4wBOIsG.B4cn81tKuBWHal.cbRrG7g8y04y","createdAt":"2025-05-07T11:47:21.772Z","updatedAt":"2025-05-07T11:47:21.772Z","__v":0}},"message":"Login Sucessfull!","success":true} 
         
         */

    }
);

export { registerUser,loginUser }